# Backlog

Non-blocking follow-ups noted during work on the upstream sprint queue. Not scheduled;
pick up when the relevant gate opens or when convenient alongside other work in the same
area. No code changes accompany entries here — this file is a record only.

## CI status (verified, not a follow-up item)

CI (`.github/workflows/ci.yml`, `rspec` matrix on Ruby 3.3/3.4/4.0 + `rubocop`) is
configured and was confirmed actually running and green, not just present, on both the
`pull_request` and post-merge `push` events for two separate PRs:

- #6a (PR #34): `pull_request` run `32553423708` (2026-08-22T05:05:17Z, success), master
  `push` run `32553764204` (2026-08-22T05:13:02Z, success).
- #33 (PR #37): `pull_request` run `32567270890` — all four jobs (RSpec ×3, RuboCop)
  passed.

Recorded here after an unverified "CI is unconfigured" claim (which only ever applied to
the sibling `openehr-rails` repo, which genuinely lacks CI) was repeated across two turns
in this repo before anyone ran `gh run list` — see `CLAUDE.md`'s
"Verify against the repo before recording a fact in it" rule, added for the same reason.

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
