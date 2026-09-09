# CKM conformance fixes — plan for #50, #51, #52

Issues: skoba/openehr-ruby#50, #51, #52 (all `bug`, `parser`; filed
2026-09-09 from skoba/openehr-japanese-translation). One issue = one
branch = one PR, sequential. Measurements backing every claim below are in
`docs/reports/ckm-conformance-log.md` R1.

## Principle

The accepting parser is lenient toward what the openEHR CKM actually
emits; strict validation belongs to the generating tool (same line as
anlage's OPT-toolchain acceptance policy, `anlage/docs/backlog.md` §7).
Each fix restores ADL 1.4 conformance — none introduces a CKM-specific
special case.

## Resolution shape

All three are **(a) bug**: a reproduction spec parsing the real CKM
artifact goes red on `master` (measured in R1: `Invalid ADL` ×2,
`ArgumentError: author is mandatory` ×1), then green with the fix.

## Fixtures — `spec/fixtures/ckm/`

Kind: **real** (CKM REST export, used as-is, byte-identical to the
download; sha256 recorded). Provenance (cid, revision, fetch date,
sha256) lives in `spec/fixtures/ckm/README.md`, because inserting a
leading comment into the file would break its as-is identity. Three
files are added, one per issue (the fourth witness, body_temperature.v2,
is cited in the spec comment but not added — person.v1 already covers the
same construct at half the size):

| Issue | File | cid | revision |
| --- | --- | --- | --- |
| #50 | `openEHR-EHR-EVALUATION.infectious_disease_summary.v0.adl` | 1013.1.1918 | 0.0.1-alpha |
| #51 | `openEHR-EHR-CLUSTER.person.v1.adl` | 1013.1.5358 | 1.0.5 |
| #52 | `openEHR-EHR-EVALUATION.problem_diagnosis.v1.adl` | 1013.1.169 | 1.7.4 |

Files are UTF-8-with-BOM, CRLF; committed unchanged (no
`.gitattributes`, no `core.autocrlf`).

## #50 — `V_ARCHETYPE_ID` rejects `.v0`

- Where: `lib/openehr/parser/adl_grammar.tt:3228`,
  `'.v' [1-9] [0-9]*`.
- Fix (issue's proposal, adopted verbatim): `'.v' [0-9]+`.
- Why it is conformance, not leniency: the archetype identification spec
  reserves `v0` for unpublished archetypes; the RM `ArchetypeID`
  (`identification.rb:71`, `\.(v\d+)\z`) and its spec already accept it.
  Only the ADL grammar disagreed.
- Scope: ADL grammar only. OPT/XML ids go through `ArchetypeID.new`
  (measured in R1: v0 root parses via `OPTParser` today).
- Spec: `spec/lib/openehr/adl_parser/adl_archetype_id_v0_spec.rb` —
  parse the v0 fixture; `archetype_id.value` ends in `.v0`,
  `version_id == 'v0'`; a second example pins that `.v1` ids still parse
  (regression pin, an existing property).
- Collision sweep: no name enters any global registry (a character class
  in one grammar rule). Not applicable.

## #51 — `archetype_slot` has no empty-block alternative

- Where: `lib/openehr/parser/adl_grammar.tt:429-452`.
- Fix (issue's proposal, adopted): a fourth alternative
  `c_archetype_slot_head SYM_MATCHES SYM_START_CBLOCK SYM_END_CBLOCK space`
  building `ArchetypeSlot.new(c_archetype_slot_head.value(node))` with
  neither includes nor excludes. Ordering: appended last, so the three
  existing alternatives keep precedence; Treetop's ordered choice means
  an empty block can only match this one.
- Why it is conformance: ADL 1.4 §5.3.x allows a slot with no assertions
  (meaning any archetype); `ArchetypeSlot#any_allowed?`
  (`constraint_model.rb:551-553`) is defined as exactly this state, and
  the XML/OPT constraint path already produces it
  (`xml_constraint_parsing.rb:105-109`).
- Spec: `spec/lib/openehr/adl_parser/adl_archetype_slot_empty_spec.rb`
  — parse person.v1; the `at0008` child is an `ArchetypeSlot` with
  `includes` and `excludes` nil, `any_allowed?` true, occurrences 0..*;
  downstream pin: `archetype.physical_paths` contains the slot's path and
  `ADLSerializer`/`XMLSerializer` accept the archetype without raising;
  a sibling slot with `include` (`at0002`) keeps its assertions.
- Collision sweep: no names added to any registry. Not applicable.

## #52 — empty `author = < >` raises in `TranslationDetails`

- Where: `lib/openehr/parser/adl_helper.rb:40`.
- Fix (issue's primary proposal, adopted):
  `:author => details['author'] || { }`. Alternative (B) — changing the
  `author=` setter — rejected: the setter already accepts `{}`, so (B)
  adds nothing unless it also maps nil→`{}`, which would loosen the RM
  invariant for every caller. No warning output (no logger convention in
  `lib/`).
- Why it is conformance: the source file violates the RM's "author
  present" expectation, but dADL `< >` is a legal empty object; the
  parser's job is to represent it (`{}`), not to reject the archetype.
- Spec: `spec/lib/openehr/adl_parser/adl_language_translation_empty_author_spec.rb`
  — parse problem_diagnosis.v1; `translations['fi'].author == {}`,
  `language.code_string == 'fi'`; a populated translation (`de`) keeps
  its author hash (regression pin).
- Collision sweep: not applicable.

## Per-PR checklist

1. Branch `fix/<N>-<slug>` from `master`.
2. Add fixture (+ README row), spec → run spec → **red** (recorded).
3. Apply fix → spec green → full `bundle exec rspec` (3973 + new
   examples, 0 failures) → `rubocop` on touched `lib/` files.
4. `History.txt`: unreleased `=== 2.4.3 (unreleased)` section at the
   top (created by PR #50's branch, appended by the others).
5. PR body: `Fixes #N`, resolution shape (a), "adopted the reporter's
   proposed patch" + any deviation, semver call (**patch**: touches
   shipped `lib/` code, corrective, no API change).
6. Rebase-merge (matches PR #47's history shape).

## Step 2 (after the three PRs)

- `History.txt` finalize `=== 2.4.3` + one line "CKM 実出力への適合";
  `version.rb` 2.4.2 → 2.4.3; tag `v2.4.3`.
- `.github/workflows/release.yml`: port openehr-rails's tag-triggered
  `ci → build → upload-artifact` (omit `rake release:check`, which is
  `lib/`-backed there; backlog).
- `CLAUDE.md`: "publish only the CI artifact" rule (sha256 comparison,
  no push from local `pkg/`).
- `gem push` stays with the human.
