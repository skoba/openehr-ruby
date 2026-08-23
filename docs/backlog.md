# Backlog

Non-blocking follow-ups noted during work on the upstream sprint queue. Not scheduled;
pick up when the relevant gate opens or when convenient alongside other work in the same
area. No code changes accompany entries here — this file is a record only.

## Session isolation: one worktree/session per repo (permanent fix, elevated priority)

**New entry (2026-08-24)** — no prior record of this item was found in this
repo's, `openehr-rails`'s, or `anlage`'s `docs/backlog.md` before this write;
recording it here now as the first record, not as a priority update to an
existing one.

**Priority: elevated after a third incident of the same class. Top priority
for environment setup once the current freeze work is past** (see
`CLAUDE.md`'s "Repository-context-dependent commands confirm their target
explicitly" rule for the incident log this responds to). The per-command
discipline (`cd`/`-C`/`-R`/`pwd`-before-call) is a mitigation, not a fix — it
depends on remembering to apply it every time, and has already failed to
prevent all three incidents it was retrofitted after. The structural fix is
to stop running one session against a cwd that drifts between multiple
repositories at all: give each repository its own persistent worktree/session
(one Claude Code session per repo, each with a cwd that never changes),
rather than one session `cd`-ing between `openehr-ruby`, `openehr-rails`, and
`anlage` and relying on per-command vigilance to keep track of where it is.
Scope of the design work when picked up: how session-per-repo affects
cross-repo tasks that currently rely on a single session's shared context
(e.g. this file's own "layer discipline" cross-references), and whether the
`Agent` tool's `isolation: "worktree"` option is a workable building block or
whether this needs a different mechanism entirely.

## CI status (verified, not a follow-up item)

CI (`.github/workflows/ci.yml`, `rspec` matrix on Ruby 3.3/3.4/4.0 + `rubocop`) is
configured and was confirmed actually running and green, not just present, on both the
`pull_request` and post-merge `push` events for two separate PRs:

- #6a (PR #34): `pull_request` run `32553423708` (2026-08-22T05:05:17Z, success), master
  `push` run `32553764204` (2026-08-22T05:13:02Z, success).
- #33 (PR #37): `pull_request` run `32567270890` — all four jobs (RSpec ×3, RuboCop)
  passed.

Recorded here after an unverified "CI is unconfigured" claim (which only ever applied to
the sibling `openehr-rails` repo) was repeated across two turns in this repo before anyone
ran `gh run list` — see `CLAUDE.md`'s "Verify against the repo before recording a fact in
it" rule, added for the same reason.

**Correction (2026-08-23)**: the "openehr-rails genuinely lacks CI" half of that claim is
now also stale — `openehr-rails`'s `master` has both `.github/workflows/ci.yml` and
`.github/workflows/release.yml`, and recent `push` runs on `master` complete successfully
(confirmed via `gh run list` in that repo). Actual run-by-run verification of that CI is
being tracked in `openehr-rails`'s own `docs/backlog.md`, not duplicated here.

**Action version bump (2026-08-23)**: `actions/checkout` bumped `v4` → `v7` in
`.github/workflows/ci.yml` (PR #42) to clear a "Node.js 20 is deprecated" warning that
every job in PR #41's run (`32610536000`) logged. Confirmed fixed, not just green, on
PR #42's own run `32610802034` — `grep -ci` across its full log for the warning text
returns 0. `ruby/setup-ruby@v1` was left unchanged; its `action.yml` already declares
`using: node24`, matching the fact that it was never named in the warning. `openehr-rails`
likely has the same class of warning in its own `ci.yml`/`release.yml` — not checked here;
that repo's own session owns verifying and fixing its own workflow files (repository
boundary rule, `CLAUDE.md`), not duplicated in this repo's tracking.

## From #6a investigation (C_CODE_REFERENCE parse crash, 2026-08-22)

- **Parser error-handling asymmetry (`XMLArchetypeParser` vs `OPTParser`)**: while
  scoping #6a's unknown-`xsi:type` fallback, we confirmed that `XMLArchetypeParser#parse`
  wraps *any* `StandardError` raised while building an archetype into
  `OpenEHR::Parser::ParseError` (`lib/openehr/parser/xml_archetype_parser.rb:21-27`,
  `rescue StandardError => e`), while `OPTParser#parse` has no such rescue at all
  (`lib/openehr/parser/opt_parser.rb:42-63`) and lets the same class of error propagate
  raw. Both classes share the same constraint-tree dispatch code
  (`XMLConstraintParsing`), so identical malformed input currently produces different
  outcomes depending only on which parser is used. #6a's fix only guards the one
  dispatch site (`children`, `xml_constraint_parsing.rb:68`) that was crashing on
  `C_CODE_REFERENCE`; the asymmetry persists for every other unguarded error path
  (the still-unguarded `attributes()` dispatch at `:52`, a structurally invalid fallback
  node, or any unrelated internal error elsewhere in either parser's build). Worth a
  deliberate design decision later: either give `OPTParser#parse` the same
  `ParseError`-wrapping rescue `XMLArchetypeParser` has, or document the asymmetry as
  intentional (e.g. because `OPTParser` callers are expected to want raw exceptions).
  See `docs/design/fix-c-code-reference-plan.md`'s "調査補遺" section for the full
  investigation (reproduced both parsers against the same unknown-type input).

## From #32 investigation (RMJSONSerializer roundtrip fix, 2026-08-22)

- **`Factory.convert_hash`'s `rescue NameError` is method-scoped, not call-scoped**:
  the rescue added for the known/unknown `_type` leniency
  (`lib/openehr/rm/factory.rb:75-90`) wraps the whole `convert_hash` method, not just
  the `Factory.create(type, **value)` call. In principle this means a `NameError`
  raised for an unrelated reason somewhere deep inside a *successfully resolved*
  Factory's `.create(...)` call (e.g. a genuine bug referencing an undefined constant
  inside some RM class's `initialize`) would also be caught here and silently
  reported as "unknown type", misattributing the real failure. In practice this is
  narrow: each nested `convert_hash` call in the recursive JSON-parsing chain has its
  own `rescue`, so the *innermost* frame where a `class_eval` failure actually occurs
  catches it first — the broader case would need a `NameError` from somewhere other
  than a missing `*Factory` constant, which no code path currently exercises. No
  action taken; recorded for awareness if a future `NameError` starts appearing to
  vanish unexpectedly during `create_from_json`.
- **`seen`-guard aliasing bug, filed as its own issue**:
  [#40](https://github.com/skoba/openehr-ruby/issues/40) (`RMJSONSerializer` silently
  drops an aliased attribute to `null`). Unscheduled. When fixed, the primary
  reproduction path is a **synthetic** two-attributes-alias-one-object fixture (see
  `CLAUDE.md`'s four-kind fixture taxonomy) — `ObjectVersionID`, this bug's original
  real-world trigger, stopped being usable as one once #32 excluded its `root`/`oid`
  pair from serialized output entirely.

## #31 (OPTParser drops `term_bindings`)

- WP2 実装知見を追記済み
  ([comment](https://github.com/skoba/openehr-ruby/issues/31#issuecomment-5383687600),
  anlage `skoba/anlage#8`)。実装着手は凍結後の第2巡。

## anlage upstream-candidates.md §8 (unfiled, independent of #31)

- anlage 台帳§8参照（`Archetype::ConstraintModel::CObject#path`が埋め込み
  C_ARCHETYPE_ROOT自身のnode_idブラケットを欠落させる）。第2巡の起票候補。
  #31 とは別問題（#31 のコメント作成時、根拠調査で同一起源かを確認し、
  混同を排除済み — 本件はパス文字列構築のバグで、#31の用語スコープ
  解決とは無関係）。anlage 側台帳の改変はしない（境界規約）。
