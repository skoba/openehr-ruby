# CKM conformance log

Running log for the "openehr-ruby 覚醒 — CKM 適合性バグ3件 (#50/#51/#52) →
2.4.3" task batch. One `R`-numbered entry per completed step, same
convention as `docs/reports/round2-prep-log.md`. Governing principle for
all three fixes (from the task brief): the *accepting* parser should be
lenient toward what the openEHR CKM actually emits — strict validation is
the generating tool's job (the same line as anlage's OPT-toolchain
acceptance policy, `anlage/docs/backlog.md` §7, 2026-08-26 ruling). Each
fix restores conformance to ADL 1.4 rather than adding a special case.

## R1 — Explore (Step 0), 2026-09-09

Baseline: `master` at `e78037a`, `bundle exec rspec` → **3973 examples,
0 failures** (Ruby 4.0.6, 3m34s). Executed directly.

### Issue citations verified against source (executed: `sed -n`)

| Issue | Cited location | Verified content |
| --- | --- | --- |
| #50 | `lib/openehr/parser/adl_grammar.tt:3228` | `rule V_ARCHETYPE_ID` body is `NAMESTR ('-' NAMESTR) 2..2 '.' NAMESTR ('-' NAMESTR)* '.v' [1-9] [0-9]*` — exactly as quoted. |
| #51 | `lib/openehr/parser/adl_grammar.tt:429` | `rule archetype_slot` has three alternatives (`c_includes c_excludes` / `c_includes` / `c_excludes`); no empty-block alternative. |
| #52 | `lib/openehr/parser/adl_helper.rb:40` | `Language#translations=` passes `details['author']` straight to `TranslationDetails.new`; `resource.rb:60-63` `author=` raises `ArgumentError, 'author is mandatory'` on nil. |

### Reproductions (executed, real CKM artifacts)

The four archetypes named in the issues were fetched directly from the CKM
REST API (`https://ckm.openehr.org/ckm/rest/v1/archetypes/<cid>/adl`,
2026-09-09T12:59Z) and compared byte-for-byte (`cmp` / `sha256sum`) with
the copies under `openehr-japanese-translation/sprint/adl/` (read-only
cross-repo reference; that directory is untracked there, so it carries no
git provenance of its own — the CKM fetch is the provenance):

| cid | archetype | revision | sha256 | identical to translation-repo copy |
| --- | --- | --- | --- | --- |
| 1013.1.1918 | `openEHR-EHR-EVALUATION.infectious_disease_summary.v0` | 0.0.1-alpha | `29d7768a517470ca0bcd5dac5a0d7e7115bbdea7fd3174b427d84cf45da8da13` | yes |
| 1013.1.5358 | `openEHR-EHR-CLUSTER.person.v1` | 1.0.5 | `69cc7845b3f4491102d32750c884bdda2593c42c869c14afeed17cd2e5c3b056` | yes |
| 1013.1.2796 | `openEHR-EHR-OBSERVATION.body_temperature.v2` | 2.1.10 | `2d478b6d2fb2e66bd1a011adc2c58a6ddbe69a6fc485fa5e3a4d25eeb231a9e2` | yes |
| 1013.1.169 | `openEHR-EHR-EVALUATION.problem_diagnosis.v1` | 1.7.4 | `8462a3b811a440c2b01451f0da48c7d297d53b5dc4d45c4722b13321e645ce1f` | yes |

(The cid for `infectious_disease_summary.v0` is not in the issue; resolved
via `GET /ckm/rest/v1/archetypes/citeable-identifier/<archetype-id>` →
`1013.1.1918`, cross-checked against the CKM search result: status DRAFT,
uid `834b8faa-…`, buildUid `24cacbf7-…` matching the file's own
`["build_uid"]`.) All four files are UTF-8 with BOM and CRLF line
terminators — the fixtures must be committed as-is (no `.gitattributes`
in this repo; WSL git has no `core.autocrlf` set, verified).

`ADLParser#parse` on each (executed, `master` e78037a):

- `1013.1.1918` (v0) → `OpenEHR::Parser::ParseError: Invalid ADL`
  ("Expected [1-9] at line 2, column 53") — **#50 reproduced**.
- `1013.1.5358` (person.v1) → `Invalid ADL` ("Expected one of [ \t\r\n],
  '--', [Ii], [Ee] at line 354, column 4") — **#51 reproduced**. The empty
  slot is `allow_archetype CLUSTER[at0008] … matches {` at line 353 of the
  CKM file (the issue says 354 — one-line offset, same construct; the
  Treetop error is reported at the closing `}` on line 354, which is
  where the issue's number comes from).
- `1013.1.2796` (body_temperature.v2) → `Invalid ADL` at the analogous
  `CLUSTER[at0062]` empty slot (file line 500/501) — #51, second witness.
- `1013.1.169` (problem_diagnosis.v1) → `ArgumentError: author is
  mandatory` from `resource.rb:61` via `adl_helper.rb:38` — **#52
  reproduced**; the `["fi"]` block with `author = < >` is at lines 25-28.

### OPT-path v0 check (Step 0 item 2 — "most important")

- `ArchetypeID.new(:value => 'openEHR-EHR-SECTION.referral_details.v0')`
  → `value` round-trips, `version_id == "v0"`. Executed. The RM regex at
  `identification.rb:71` is `\.(v\d+)\z` — it never required `[1-9]`.
  `spec/lib/openehr/rm/support/identification/archetype_id_spec.rb:63-81`
  already pins a v0 case.
- `OPTParser.new('spec/lib/openehr/opt_parser/new_constraints_template.opt').parse`
  → succeeds; the definition contains a `C_ARCHETYPE_ROOT` with
  `archetype_id` `openEHR-EHR-OBSERVATION.vital_signs.v0` (executed; the
  same fixture is exercised by
  `opt_parser_new_constraints_spec.rb:215`). OPT/XML archetype ids are
  built through `ArchetypeID.new(value: …)`
  (`xml_archetype_parser.rb:66-67`), not the ADL grammar.
- **Conclusion: #50 is confined to the ADL grammar; no OPT-path scope
  extension.** jp_referral's `referral_details.v0` diagnosis therefore
  depends only on the ADL fix (if it enters via ADL) or on nothing at all
  (if it enters via OPT).

### #51 downstream (Step 0 item 3)

- `ArchetypeSlot` (`constraint_model.rb:528-554`) accepts nil
  `includes`/`excludes` and defines `any_allowed?` as exactly that state —
  an empty slot is the designed "any archetype" representation, not an
  edge case.
- The XML/OPT constraint path already constructs slots with nil
  includes/excludes when the elements are absent
  (`xml_constraint_parsing.rb:105-109`), so every OPT-fed downstream
  (`physical_paths` via `each_constraint_node`, `archetype.rb:128-131`;
  `ADLSerializer` `adl_serializer.rb:225,361`; `XMLSerializer`
  `xml_serializer.rb:212,247`) has been receiving nil-slot instances since
  those parsers landed. The #43 path issue concerns `C_ARCHETYPE_ROOT`
  node_id brackets, orthogonal to slots. Downstream behavior on the ADL-fed
  slot will be pinned in the #51 spec (`physical_paths` contains the slot
  path; serializers accept the slot).

### #52 design comparison (Step 0 item 4)

- (A) parser-side `details['author'] || { }` in `adl_helper.rb:40`: keeps
  the RM invariant (`author` non-nil) intact and expressed in one place;
  touches only the accepting parser, matching the governing principle.
- (B) `TranslationDetails#author=` accepting `{}` while rejecting nil:
  the setter already accepts `{}` (it only checks nil), so (B) by itself
  changes nothing — the parser must still convert nil to `{}` before
  calling the setter. (B) only adds value if the setter itself mapped
  nil→`{}`, which loosens the RM class for every caller, not just the
  parser.
- **Chosen: (A).** No warning output: `lib/` has no logger convention
  (`grep -rn "Logger\|logger" lib` → nothing; the only `warn` is the
  `node_ids_vaild?` deprecation shim), and tolerant acceptance is the
  deliberate policy, not a degraded mode.

### Other facts established for Steps 1-3

- Existing ADL fixtures live in `spec/lib/openehr/adl_parser/adl14/`
  (98 files, loaded through `adl14_archetype`, `parser_spec_helper.rb`).
  Per the task brief the CKM artifacts go under `spec/fixtures/` instead
  (`spec/fixtures/ckm/`), as real artifacts used as-is. Because they are
  used as-is (byte-identical to the CKM download, verifiable by sha256),
  the required kind/provenance comment lives in a sidecar
  `spec/fixtures/ckm/README.md` and in each spec, not inside the ADL
  files.
- Previous PR (#47) was rebase-merged onto `master` (`a7f4346`'s parent
  is the preceding master commit; no merge commit). Branch naming:
  `fix/<issue>-<slug>`.
- `History.txt` is this gem's changelog (no `CHANGELOG.md` exists); the
  task's "CHANGELOG [2.4.3]" maps to a `=== 2.4.3` section there.
- `.github/workflows/` has only `ci.yml` (rspec matrix 3.3/3.4/4.0 +
  rubocop); **no `release.yml`**. openehr-rails's `release.yml` runs `ci`
  → `rake release:check` → `rake build` → `upload-artifact` on `v*` tags;
  `release:check` is backed by a `lib/` class there (`OpenehrRails::
  ReleaseCheck`), so a docs/CI-only port here carries the build+upload
  steps and omits `release:check` (recorded as backlog).
- The "acceptance policy item 7" referenced by the task brief is
  `anlage/docs/backlog.md` §7 ("OPT生成ツールチェーンの受け入れポリシー
  — 確定版（2026-08-26裁定）"); it is not in this repo or in
  openehr-japanese-translation.
- `tools/setup_openehr.sh` in openehr-japanese-translation (read at
  `b3bdb12`) applies exactly the three patches the issues propose (sed on
  `V_ARCHETYPE_ID`, a fourth `archetype_slot` alternative, `|| { }` on
  author); the corpus it processes is `sprint/adl/` (36 files) plus
  `archetypes/<id>/<id>.adl` (4 so far).

Plan written to `docs/design/ckm-conformance-plan.md`. Approval gate: the
task brief itself prescribes the three fixes ("提案どおりの最小修正") and
the fixture policy, so implementation proceeds on that authorization.
