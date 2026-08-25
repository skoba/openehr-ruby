# Round 2 prep log

Running log for the "短期覚醒 — AQL 制約2件の起票+第2巡弾倉整備" task batch
(docs/Issue のみ・リリースなし). One `R`-numbered entry per completed step,
same convention as `docs/reports/pre-freeze-wave-log.md`. This task's gate
was a single plan approval (two full issue drafts bundled in the plan file).

## R1 — Explore + draft (background workflow, 6 agents)

Ran a 6-agent background workflow (3 read-only Explore agents over
openehr-ruby / anlage / GitHub state, 3 Plan agents drafting the two issue
bodies and the backlog magazine section from those reports), then spot-
verified every load-bearing citation directly (Read/grep/git) before
writing the plan.

Refinements found during this step (both folded into the plan/issue
drafts, per #43's "refine the downstream observation against real source"
pattern):

- Ledger item 11 cites `history.rb:21` for the missing `time`
  `path_attribute` declaration; `:21` is actually `History`'s own
  `path_attribute :events, :summary` (the `events` hop that *does* work).
  The real gap is `Event`'s `path_attribute :data, :state` at `:53`,
  which omits `:time`. Confirmed via `grep -rn "path_attribute :" lib` —
  no declaration anywhere in `lib/` includes `:time`. The ledger's
  substantive claim (no `path_attribute` declares `:time`) holds; only
  the cited line number was corrected.
- `git log -S ALLOWED_TERMINAL_HOPS` confirms the constant was introduced
  in exactly one commit (`fa6f6c4`, "AQL engine E4: SELECT path
  evaluation") and never modified since. The commit message and the
  surrounding class comment both record the restriction's rationale
  explicitly ("never an arbitrary send driven by query text" + "Expand
  only when a real query needs another one") — so item 10's issue states
  the recorded rationale as measured fact rather than treating it as
  unknown, and narrows the open questions to performance (unattested) and
  syntax-scoping (plausible but unconfirmed).
- Verified `DvCodedText#defining_code` (`text.rb:141`) and
  `CodePhrase#code_string` (`text.rb:61`) are both public `attr_reader`s
  — upgrades item 10's Option A from "should work" to "confirmed to
  resolve via the existing whitelisted `public_send`".
- Cross-repo spot-checks (read-only, target explicit): confirmed
  `openehr-rails`'s `populate_term_bindings!` nil-guard
  (`lib/openehr_rails/opt/parser.rb:52-56`) and `anlage`'s Q4
  original/adopted queries and q20 eval-seed note verbatim against
  their own repos, per the repository-boundary rule.
- GitHub-state check: no open or closed `skoba/openehr-ruby` issue covers
  EVENT.time or ALLOWED_TERMINAL_HOPS before this task — both are new
  filings, not duplicates.

Plan written to `/home/skoba/.claude/plans/openehr-ruby-velvet-hickey.md`,
including both full issue drafts and the backlog section draft, and
approved via a single gate.

## R2 — Issues filed

- `skoba/openehr-ruby#48` — "AQL path evaluation cannot reach EVENT.time:
  events[...]/time is missing from both the path_attribute declarations
  and ALLOWED_TERMINAL_HOPS" (label `bug`, resolution shape (a)).
- `skoba/openehr-ruby#49` — "AQL PathEvaluator's ALLOWED_TERMINAL_HOPS
  blocks defining_code/code_string — relax the terminal-hop whitelist for
  code-value WHERE (design discussion)" (label `enhancement`, resolution
  shape (b)).

Cross-references applied after filing (`gh issue edit --body-file`): #48's
Summary now names #49 for the sibling `defining_code`/`code_string`
limitation; #49's Option B paragraph now names #48 for the sibling
`EVENT.time` limitation.

## R3 — Backlog magazine section

Appended `## Round 2 magazine (第2巡マガジン — 仮置き優先順, 2026-08-25)`
to the end of `docs/backlog.md`, with real issue numbers (`#48`, `#49`)
substituted for the plan's `#ITEM11`/`#ITEM10` placeholders. Priority
order: #48 and #31 tied at 1st, #43 at 3rd, #49 at 4th, #36 at 5th — with
#31's row naming both detour holders (anlage `PathcardExtractor`, rails
`populate_term_bindings!`) and the removal-cascade cross-reference.

## R4 — Convention/template additions

- `CLAUDE.md`: added a Contribution-workflow bullet requiring a
  collision sweep across all classes for any plan that adds names to a
  global namespace (exclusion/allow list, reserved keys, etc.), citing
  #46/PR #47's `:@name`/`:@version_id` collision as the worked example.
- `.github/ISSUE_TEMPLATE/bug_report.md`: extended the Environment
  section's comment to ask for the OPT/ADL generating tool and version
  (e.g. Better Archetype Designer / Ocean Template Designer 2.6).

## R5 — Push + CI

(recorded after push, same after-the-fact convention as
`pre-freeze-wave-log.md` R12)
