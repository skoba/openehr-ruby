# Pre-freeze wave log

Running log for the "冬眠中の宿題回収" (#35 execution + §8 filing draft + #40 fix +
release) task batch. One `R`-numbered entry per completed step; chat itself is
limited to two gates (plan+draft approval, then merge+tag approval) per the
task's own instruction, so this file is the place-by-place record in between.

## R1 — Part 1: #35 executed (no gate — pre-approved content)

The `docs/ticket-driven-workflow` branch (created 2026-08-22, before this task
was paused) already contained exactly the content Part 1 specified — verified
by reading its single commit (`02da6e2`) in full before reusing it, rather
than rewriting from scratch:

- `CLAUDE.md`'s "Ticket-driven workflow" section: Issue required before a
  runtime-behavior/public-API/install-dependency change starts; docs/CI/dev
  config optional; three resolution shapes (bug = red-first, enhancement =
  red-first, pin/hardening = explicit "regression pin", no staged fake-red);
  one issue = one branch = one PR; `Fixes #N`; a `docs/design/` plan states
  its issue number up front.
- `.github/ISSUE_TEMPLATE/bug_report.md` — Summary / Environment /
  Reproduction / Expected vs Actual / Root cause / Proposed fix / Acceptance
  criteria.
- `.github/ISSUE_TEMPLATE/enhancement.md` — Motivation / Current behavior /
  Proposed behavior / Acceptance criteria / Compatibility notes (the
  runtime/public-API/install-dependency surface).
- `.github/ISSUE_TEMPLATE/config.yml` — `blank_issues_enabled: true`.

Cherry-picked (`02da6e2` → `e9e544d`, auto-merged cleanly against master's
accumulated `CLAUDE.md` changes) rather than rewritten, since the content
already matched. First push was rejected non-fast-forward — `origin/master`
had moved (PR #42, the Node 20 CI fix, was merged directly by the user at
`2026-08-23T02:13:24Z`, independently of this task). Rebased onto the new tip
(`e9e544d` → `00c394d`) and pushed clean:

```
7633117..00c394d  master -> master
```

`Fixes #35` in the commit message auto-closed the issue on push — confirmed
via `gh api repos/skoba/openehr-ruby/issues/35`: `state: closed`,
`closed_at: 2026-08-23T03:54:57Z`.

## R2 — Part 2: §8 draft (bug_report.md template, first application)

Drafted `.github/ISSUE_TEMPLATE/bug_report.md`-shaped issue for anlage
`upstream-candidates.md` §8 (`CObject#path` drops an embedded
`C_ARCHETYPE_ROOT`'s own node_id bracket). Full text held for gate-1 delivery
(see task instruction: draft bundled with Part 3's plan in one message).

**Material upgrade over anlage's own framing**: anlage's ledger marks the
root cause "推定、未確定" (hypothesis, unconfirmed) — a guessed `node_id=`/
`.path`-accessor ordering race in `CObject#path`'s memoization
(`constraint_model.rb:126-128`). Tracing the actual parser code
(`lib/openehr/parser/xml_constraint_parsing.rb`'s `c_archetype_root`,
lines 18-29) instead: the real cause is that its `if node.root? or
node.id.nil?` guard (lines 24-26) only ever handles the top-level-root case
and has no branch appending `[node_id]` for an embedded root — unlike
`c_complex_object` (lines 31-38), which does exactly that. **Empirically
confirmed, not just traced**: ran a reproduction against
`spec/lib/openehr/opt_parser/eReferral.opt` (a real fixture already in this
repo, no new fixture needed) — all 40 embedded `C_ARCHETYPE_ROOT` nodes in
that file are missing their own bracket, 100% reproduction rate, no
exceptions. Also checked existing-spec impact: `grep -rln
'physical_paths\|logical_paths'` shows every existing spec exercising these
methods uses a synthetic single-root `Archetype`, so none currently cover
the embedded case and none are expected to need updating once fixed.

Draft filed only after gate-1 approval, via `gh` (not yet executed).

## R3 — Part 3 explore (a)/(b)/(c): #40

Ran a background workflow (2 parallel agents) for (a) cycle inventory and
(b) aliasing grep across the whole `lib/openehr/rm/` and `lib/openehr/am/`
trees; did (c) impact-scope analysis directly, including a standalone
push/pop simulation (not touching real source) and a live reproduction
against the actual `RMJSONSerializer`/`OperationalTemplate` code.

**(a)**: no genuine, currently-reachable cycle exists in the RM/AOM graph
beyond `@parent`, and `@parent` (both its RM/`Pathable` and AOM/
`ArchetypeConstraint` instances) is already fully excluded. No other
back-reference ivar family exists anywhere in `lib/openehr/`. Confirms
Cycle 2 of the plan (true-cycle regression pin) must be synthetic — no real
class can currently demonstrate an unexcluded cycle.

**(b)**: `ObjectVersionID`'s `@root = @oid` aliasing is still present
internally (not removed by #32, only masked from output). **New finding**:
`OperationalTemplate#template_id=` (`lib/openehr/am/template.rb:31-38`)
aliases `@template_id`/`@archetype_id` to the identical object, and is
**not** masked — independently reproduced twice (workflow + directly by me,
`bundle exec ruby -e '...'`): `template_id.equal?(archetype_id) == true`,
and the second `object_value` call for the same object returns `nil` while
the first returns its real serialized value. This upgrades #40's own prior
assumption ("primary reproduction path is a synthetic fixture") — a real,
already-shipped class now reproduces the bug unmasked, preferred per this
repo's fixture taxonomy. Flagged as the plan's one open decision point.

**(c)**: verified via isolated simulation that push-on-enter/pop-on-exit
fixes aliasing (both occurrences serialize real values) while still
catching genuine cycles (no infinite recursion). Also found the existing
"excludes the parent back-reference" spec (`rm_json_serializer_spec.rb:92-99`)
never actually exercises the `seen` guard at all — `@parent` is filtered
out of `instance_variables` before recursion, so it passes via exclusion
alone. Confirms Cycle 1's regression-pin spec is the first spec to
genuinely exercise cycle-catching behavior.

## R4 — Part 3 plan written

`docs/design/fix-seen-guard-aliasing-plan.md` — Decision (push/pop shape,
no `EXCLUDED_IVARS` change), 5 TDD cycles (Cycle 1 = regression pin written
first per the Ticket-driven workflow's resolution-shape rule — the true-cycle
case is already green today, so staging it as fake-red would violate the
very rule just added in Part 1; Cycle 2 = red via `OperationalTemplate`;
Cycle 3 = minimal green; Cycle 4 = full-suite regression; Cycle 5 =
refactor-if-needed), History.txt compatibility-note draft, acceptance
criteria mapping. One open question carried to gate 1: confirm
`OperationalTemplate` over a synthetic fixture for Cycle 2's reproduction.

**Gate 1 due next**: plan + §8 draft (R2) submitted together in one message.

## R5 — Gate 1 approved; Part 2 executed

§8 draft filed: [#43](https://github.com/skoba/openehr-ruby/issues/43)
(`Archetype#physical_paths`/`#logical_paths` drop an embedded
C_ARCHETYPE_ROOT's own node_id bracket), labels `bug`,`parser` — first
application of the new `bug_report.md` template (Part 1). Confirmed
fence-balanced (10 `` ``` `` lines = 5 pairs) before filing.

## R6 — Part 4: #40 implemented, PR #44 open, CI green

Codex ran all 5 cycles (background, resumed once after a tool timeout).
Diff matches the plan exactly: `object_value` gains `seen.delete(value)`
before returning; two specs added (inline synthetic regression pin +
real-`OperationalTemplate` red-then-green). Independently re-verified:
`bundle exec rspec spec/lib/openehr/serializer/rm_json_serializer_spec.rb`
(11/0), full suite (3970/0), `rubocop` on touched files (0 offenses).
`History.txt`'s 2.4.1 unreleased section got #40's entry, added at merge
time per this repo's own rule. Committed with `Implemented-by: Codex`,
pushed, PR [#44](https://github.com/skoba/openehr-ruby/pull/44) opened
(`Fixes #40`, `Related: #43`). All 4 CI jobs green
(run `32618969257`).

Before committing, corrected two internal inconsistencies found in the plan
doc itself (Cycle numbering had "Cycle 0" vs the canonical "Cycle 2" for the
same spec in different paragraphs; added the fixture-taxonomy scope note
for the inline synthetic cycle object) — see `fe2ca2d` on
`fix/40-seen-guard-aliasing`.

## R7 — Step 6 inventory (v2.4.0..master, PR #44 not yet merged)

13 commits since `v2.4.0`, classified by actual diff content (not
category-guessing):

| Commit | Touches | Class |
|---|---|---|
| `9c296c8` | `docs/backlog.md`, `docs/design/*.md` | neutral |
| `cde795c` | `CLAUDE.md` | neutral |
| `bb2a5ec` | `docs/design/*.md` | neutral |
| `dfb4f2a` | `lib/openehr/aql/{errors,parser}.rb` (+ spec) | **patch** (#38) |
| `0682d0e` | `History.txt` | neutral |
| `142f273` | `CLAUDE.md` | neutral |
| `4ca4950` | `docs/backlog.md` | neutral |
| `97eb2f4` | `CLAUDE.md` | neutral |
| `0c203af` | `.github/workflows/ci.yml` | neutral (CI config) |
| `7633117` | `docs/backlog.md` | neutral |
| `00c394d` | `.github/ISSUE_TEMPLATE/*`, `CLAUDE.md` | neutral (#35) |
| `0ee7489` | `docs/reports/*.md` | neutral |
| `96fc01e` | `docs/reports/*.md` | neutral |

Plus PR #44 (pending merge): `lib/openehr/serializer/rm_json_serializer.rb`
(+ spec, `History.txt`) → **patch** (#40).

`#43` (§8) is issue-only — no code change, no diff entry, deferred to the
next round. `#35` shipped as docs/templates only, correctly neutral despite
being a governance change (matches the Release convention's own test:
runtime/public-API/install-dependency surface, which issue templates and
CLAUDE.md prose don't touch).

**Version proposal: 2.4.1, patch.** Exactly two commits touch shipped
runtime code across the whole range (`dfb4f2a` for #38, plus PR #44's
commit for #40 once merged) - both are genuine, observable behavior fixes
(diagnostic-message addition, aliasing-serialization correction), neither
adds/changes public API surface or install-time dependencies. No minor- or
major-triggering change exists in the range. This confirms, not just
carries forward, the "2.4.1 patch" placeholder from the task instruction.

**Gate 2 due next**: PR #44 merge approval + this inventory + version
proposal + release report, in one message.

## R8 — Gate 2 executed: PR #44 merged, v2.4.1 tagged and built

1. `gh pr merge 44 --rebase --delete-branch` — merged (`0abb63a`), remote
   branch auto-deleted.
2. Post-merge on master: `bundle exec rspec` → 3970 examples, 0 failures.
   `#40` auto-closed (`closed_at: 2026-08-23T04:58:08Z`). `#43`'s
   cross-reference from PR #44 confirmed present via the issue timeline API.
3. `History.txt`'s `2.4.1` section finalized (dropped the "(unreleased)"
   placeholder header/sentence, added a one-line release summary matching
   this file's existing style). `lib/openehr/version.rb` bumped
   `2.4.0` → `2.4.1` in a dedicated "Release: bump version" commit
   (`6cb8605`), matching this repo's pre-session precedent for that
   commit shape. Tagged `v2.4.1` (annotated), pushed:
   `6cb8605627a0b4d0d9182e16906a021f6ed7e997`.
4. `bundle exec rake build` →
   `pkg/openehr-2.4.1.gem`, sha256
   `70c1949a87beaa4cb8bdfb9bca4a1c2c9af2e93e283c70d9cddbaad8996c8f6c`.
   `gem push` intentionally not run — stays the user's own action, after
   independently verifying this checksum (standing rule).
5. Local branch hygiene: deleted `ci/update-action-versions` and
   `docs/ticket-driven-workflow` (both fully content-merged into master,
   verified via `git diff <branch> master` before deleting the latter,
   which cherry-pick had made unrecognizable to git's own merged-branch
   check). `origin/ci/update-action-versions` still exists remotely
   (PR #42 was merged directly, not via `gh pr merge --delete-branch`) -
   left as-is, minor housekeeping not requested this round.

**Final OPEN-issue shape, as expected**: #31 (term_bindings, round 2),
#36 (STRICT-mode discussion), #43 (CObject#path bracket, round 2) - three
versioned backlog items plus one discussion issue. #35/#38/#40 closed this
batch. openehr-ruby returns to dormant.
