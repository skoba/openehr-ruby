# Plan: AQL parser — hint SELECT-alias-in-WHERE errors (#38)

## Context

[Issue #38](https://github.com/skoba/openehr-ruby/issues/38): when a WHERE
clause contains a leftover identifier that happens to match a SELECT alias
name (e.g. editing away `AS height` but leaving a stray `height` token
behind), the parser raises a correct but unhelpful error:

```
expected a comparison operator, LIKE or MATCHES, got identifier "height"
(line 2, column 172)
```

The column number is precise, but nothing tells a SQL-background user that
AQL SELECT aliases are result-column names, not WHERE-usable bindings. This
is diagnostics-only: AQL doesn't support alias references in WHERE, and this
change must not start supporting them.

Traced to a demo-time incident; the accompanying pin-down of the demo query
itself is tracked separately as `skoba/anlage#5` (anlage's own repo, not
touched by this plan or its implementation — see CLAUDE.md's repository
boundary rule).

## Explore results (file:line verified against master @ 08ebbaa)

- The error site is `parse_identified_expr`'s final `else` branch,
  [lib/openehr/aql/parser.rb:301](../../lib/openehr/aql/parser.rb#L301):
  `raise error("expected a comparison operator, LIKE or MATCHES, got #{describe(peek)}")`.
  Confirmed this is reached exactly when `parse_identified_path` has already
  consumed the WHERE-side path and the next token is neither a
  `comparison_operator`, `LIKE`, nor `MATCHES` (parser.rb:290-303).
- SELECT aliases are captured per-column already: `parse_select_expr`
  (parser.rb:66-71) builds `Model::SelectColumn#alias_name` from an optional
  `AS IDENTIFIER`. `parse_select_clause` (parser.rb:44-52) collects these
  into `Model::SelectClause#columns`, confirmed immutable/frozen
  (`lib/openehr/aql/model/select_clause.rb:5-26`).
- That `Model::SelectClause` is **not retained as parser state**: in
  `parse_select_query` (parser.rb:25-34) it's a local variable
  (`select_clause`) used only to build `Model::Query`, then discarded from
  the parser's perspective. `parse_identified_expr` (reached later, while
  parsing WHERE) has no path back to it. Confirmed `Parser`'s only ivars are
  `@tokens`/`@pos` (parser.rb:14-17) — no existing alias-tracking state to
  extend.
- `ParseError` (`lib/openehr/aql/errors.rb:11-20`) builds its message as
  `"#{message}#{location}"`, where `location` is `" (line L, column C)"` or
  `''`. There is currently no hook for a third message segment after the
  location — the proposed format (`note: ...` on its own line, after the
  location) needs a new optional constructor argument.
- No spec currently exercises the `"expected a comparison operator, LIKE or
  MATCHES"` message at all (`grep` across `spec/lib/openehr/aql/` returns no
  hits) — this is a pure coverage gap, not a case of an existing assertion
  that needs updating.
- `spec/lib/openehr/aql/parser_spec.rb`'s `M9: trailing "--" and error
  quality` describe block (parser_spec.rb:623-652) is the existing home for
  message/line/column-quality assertions, structured as a
  `{description => [source, line, column, message_fragment]}` table feeding
  one shared `it`. This is the natural place to add both the new hinted case
  and an explicit non-alias control case (same identifier-in-WHERE shape,
  but the trailing identifier isn't a SELECT alias) — the latter exists to
  satisfy the issue's second acceptance criterion ("no change to the
  ordinary case") as an actual regression spec, not just an assertion in
  this plan.

## Decision

Add parser state, not a threaded parameter. Threading the alias set as an
extra argument through `parse_where_clause` → `parse_or_expr` →
`parse_and_expr` → `parse_not_expr` → `parse_where_primary` →
`parse_identified_expr` would touch five method signatures for a value only
the last one needs. Instead: `parse_select_clause` sets an ivar,
`@select_aliases` (a `Set` of alias-name strings, possibly empty — never
`nil`, so callers don't need a nil-guard), right before returning. This
mirrors the existing `@tokens`/`@pos` ivar style and keeps every
intermediate WHERE-parsing method's signature unchanged.

`ParseError` gains an optional `hint:` keyword argument, appended after the
location as `"\nnote: #{hint}"` when present, `''` when not — matching the
issue's proposed format exactly and leaving every existing `ParseError.new`
call (none of which pass `hint:`) byte-for-byte unchanged in output.

`parser.rb`'s private `error(message, hint: nil)` helper gains the same
optional parameter, passed through to `ParseError.new`. Only the one call
site in `parse_identified_expr`'s final `else` branch will ever pass it:

```ruby
else
  identifier = peek.type == :identifier ? peek.value : nil
  hint = if identifier && @select_aliases.include?(identifier)
           "'#{identifier}' is a SELECT alias; aliases cannot be used in WHERE -- repeat the identified path"
         end
  raise error("expected a comparison operator, LIKE or MATCHES, got #{describe(peek)}", hint: hint)
end
```

No change to what's a valid vs. invalid WHERE clause: the branch still
always raises; only the raised message gains a trailing line in the one
case where the offending identifier matches a known SELECT alias.

## TDD cycles (t-wada: red → green → refactor)

1. **Cycle 0 (red)** — acceptance spec reproducing the issue's exact
   scenario: `SELECT o/.../magnitude AS height FROM ... WHERE
   o/.../magnitude height > 170` raises `ParseError` whose message includes
   `note: 'height' is a SELECT alias`. Expected failure: message lacks the
   `note:` line (current behavior).
2. **Cycle 1 (green, minimal)** — add `ParseError`'s `hint:` kwarg and
   `parser.rb`'s `error(message, hint: nil)` plumbing; add
   `@select_aliases` population in `parse_select_clause`; add the
   alias-check branch in `parse_identified_expr`. Confirm Cycle 0 goes
   green.
3. **Cycle 2 (regression, red → green)** — add the non-alias control case
   (same shape, trailing identifier isn't a SELECT alias) asserting the
   message is **unchanged** from today's (no `note:` line). This should be
   green immediately if Cycle 1's alias check is correctly scoped — if it's
   red, Cycle 1's implementation is over-firing and needs narrowing before
   proceeding.
4. **Cycle 3 (regression)** — run the full `spec/lib/openehr/aql/` suite
   (existing M1-M9 tests plus `real_world_examples_spec.rb`,
   `examples_spec.rb`) to confirm no other `ParseError`-message assertion
   changed shape. All existing `ParseError.new` call sites in `lexer.rb` and
   `parser.rb` omit `hint:`, so this is expected to be a no-op for them, but
   this cycle verifies it rather than assuming it.
5. **Cycle 4 (refactor)** — none anticipated beyond what Cycles 1-3 already
   produce; the change is small and self-contained. If Cycle 1's inline
   hint-construction reads awkwardly once written, consider extracting a
   small private `alias_hint(identifier)` helper — judgment call at
   implementation time, not a planned step.

## Semver

**Patch.** Touches shipped runtime code (`lib/openehr/aql/parser.rb`,
`lib/openehr/aql/errors.rb`) — per CLAUDE.md's Release convention, that's a
minimum-patch floor regardless of behavior classification. No public API
addition (the `ParseError#hint`... actually: **open question, resolve during
review** — see below) — no new public method, no changed method signature
for any existing caller (`hint:` is optional, defaults preserve prior
behavior byte-for-byte), no dependency change. Diagnostics-only per the
issue's explicit constraint (no new WHERE-clause grammar support).

Open question for review, not blocking approval: should `ParseError` expose
a public `#hint` reader (mirroring its existing `#line`/`#column` readers)
so callers can distinguish "has a hint" programmatically, or is folding it
into `#message` sufficient? The issue's acceptance criteria only test
`e.message`, so the minimal implementation doesn't need a reader — leaving
this to be decided during implementation review rather than gating plan
approval on it.

**Ruling (2026-08-23)**: no `#hint` reader — fold into `#message` only.
Reasons: don't add an untested public API surface; keep the change's
footprint inside the patch classification above; if a real caller need for
a structured `#hint` ever materializes, that's a separate issue with its
own use case to design against, not something to pre-build speculatively
here.

**Existing spec message-assertion audit (measured, 2026-08-23)**: grepped
`spec/lib/openehr/aql/**/*.rb` for every `ParseError`/`DatasetError`/etc.
message assertion. Result: zero specs assert a `ParseError` message by full
equality (`eq`). Every existing assertion is one of: type-only
(`raise_error(OpenEHR::AQL::ParseError)`, parser_spec.rb:58 and others),
substring/regex (`raise_error(OpenEHR::AQL::ParseError, /FROM/)`,
parser_spec.rb:53; `lexer_spec.rb:169`), or `expect(e.message).to
include(message_fragment)` (the M9 table, parser_spec.rb:648). Regex/`raise_
error`'s second-argument form matches via substring, not full equality
(RSpec's built-in behavior). Conclusion: appending a `\nnote: ...` line
after the location cannot break any *existing* assertion by construction —
there is no existing exact-match case to audit case-by-case before Cycle 1;
Cycle 3 (full-suite run) remains the empirical backstop.

## Acceptance criteria (from #38, restated)

- [ ] Cycle 0's spec: alias-matching case includes the `note:` hint line.
- [ ] Cycle 2's spec: non-alias case's message is byte-for-byte unchanged
      from current behavior.
- [ ] No change to what's a valid vs. invalid WHERE clause (no new spec
      needed for this — it falls out of the fact that the `else` branch's
      `raise` is unconditional either way; Cycle 3's full-suite run is the
      empirical check).

## Files touched

- `lib/openehr/aql/errors.rb` — `ParseError#initialize` gains `hint:`.
- `lib/openehr/aql/parser.rb` — `error()` gains `hint:`; `parse_select_clause`
  sets `@select_aliases`; `parse_identified_expr`'s final `else` computes
  and passes the hint.
- `spec/lib/openehr/aql/parser_spec.rb` — two new cases in the `M9` table
  (or adjacent `it` blocks, whichever reads more clearly once the exact
  hint string is in hand — table form is preferred for consistency with the
  existing block, used unless the hint text makes the table row awkwardly
  long).
- `History.txt` — new entry under the next unreleased version header (added
  at Step 6 / tagging time per existing precedent, not in the implementation
  commit itself — see `bf17be7` for the precedent of a docs-only commit that
  didn't touch `History.txt`; this one does touch `lib/`, so it does need an
  entry, just at release time alongside the semver call above). The entry
  **must include an explicit compatibility note**: any code parsing
  `ParseError#message` by exact string match (not this gem's own specs —
  see the audit above — but a downstream caller's) could see a new trailing
  `\nnote: ...` line in the one alias-collision case; every other message
  is byte-for-byte unchanged.

## Release sequencing

**Ruling (2026-08-23)**: do not cut a release for #38 alone. It rides along
with whichever of #31 (term_bindings source_xml reparse, still open) or #40
(seen-guard aliasing bug, still open/unscheduled) ships next — batch into
that release's semver/History.txt inventory rather than tagging a
standalone patch release for a diagnostics-only change.

## Fixtures

None needed — this is a pure parser/error-message change exercised entirely
through inline AQL source strings in specs (as the existing M1-M9 tests
already do), not through any file fixture. No fixture-taxonomy comment
applies.
