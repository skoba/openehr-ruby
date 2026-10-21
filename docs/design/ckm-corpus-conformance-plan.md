# Plan: CKM corpus conformance smoke (#56)

Issue: [#56](https://github.com/skoba/openehr-ruby/issues/56). Resolution
shape: **(b) enhancement** - a new opt-in spec that parses every archetype
of a reference CKM corpus; the same spec goes red against the pre-2.4.3
parser (4 of the corpus files fail there) and against any corpus directory
containing an unparsable file, green on `master` ≥ 2.4.3 against the
reference corpus.

Status: **approved 2026-09-21** with four notes, all folded in below:
(1) design as proposed - per-file examples (deviation adopted for
diagnostic value), exception class not restricted, scheduled workflow
separate from `ci.yml`, semver neutral; (2) pinned mode (`82cf80b`, 41
files) is for reproducing the spec, the weekly job runs live against the
translation project's `HEAD` - early detection of new CKM constructs as
the corpus grows is the point of #56; (3) the README gets a "when a run
goes red" section (CKM revision, cid, line, Treetop reason → parser
issue in the #50-#52 format; a red live run is a detection, not a
defect); (4) the serializer second pass is left as one line on the issue
for v2; the red procedure (broken-file scratch dir + v2.4.2 worktree
reproducing the 4 predicted failures) is approved as a reusable pattern.
Post-implementation: bundle report (push SHA, CI run, first scheduled/
dispatched run), then dormant. Sibling plan for the
three fixes that motivated this: `docs/design/ckm-conformance-plan.md`
(#50/#51/#52, shipped in 2.4.3).

## Context

#50, #51 and #52 were all found by the same route: skoba/openehr-japanese-
translation ran the vendored parser over real CKM exports and hit
constructs the ADL 1.4 grammar/helper rejected. Three sightings from one
batch is a rate, and the translation project's target set keeps growing
(its `sprint/adl/` corpus was re-fetched as recently as 2026-09-20 per its
`manifest.tsv`). Today this repo's only guard is the frozen 98-file
`spec/lib/openehr/adl_parser/adl14/` corpus plus the three real fixtures
under `spec/fixtures/ckm/`; neither tracks what the CKM currently
publishes. #56 asks for a periodically-run smoke over the live reference
corpus, referenced by pointer + fetch procedure rather than copied.

## Explore results

Verified against `master` @ `237a34c` (this repo) and
skoba/openehr-japanese-translation @ `82cf80b` (read-only, evidence only -
that repo's HEAD moved from `9d9d0bc` to `82cf80b` *during* this
exploration, so another session is actively committing there; nothing
here writes to it).

### (1) Parser API the spec drives

- `OpenEHR::Parser::Base#initialize(filename)` stores the path
  (`lib/openehr/parser.rb:34-36`); `ADLParser#parse(validate: false)`
  builds the archetype and only runs `ArchetypeValidator` when asked
  (`lib/openehr/parser/adl_parser.rb:11-15`). The smoke uses the default
  (`validate: false`) - the question is "does the CKM's output parse", not
  "is it valid against the RM".
- Grammar rejection raises `ParseError, 'Invalid ADL'`
  (`adl_parser.rb:31`) **after** `puts`-ing Treetop's `failure_reason` /
  `failure_line` / `failure_column` to stdout (`adl_parser.rb:27-29`). So
  the exception message alone never says *where* the grammar stopped; the
  position lands on stdout just above RSpec's failure block. The spec
  doesn't need to capture that - it only has to name the file (example
  description) and surface the exception (RSpec's `raise_error` negation
  prints class + message).
- Not every corpus failure is a `ParseError`: #52's was an `ArgumentError`
  ("author is mandatory") raised from an RM constructor during the build
  phase. The spec must therefore assert `not_to raise_error` (any
  exception), not `not_to raise_error(ParseError)`. This matches the
  issue's "ParseError/exception" wording.
- `ParseError` is `StandardError` (`lib/openehr/parser.rb:43`).

### (2) How the existing corpora are exercised

- `spec/lib/openehr/adl_parser/parser_spec_helper.rb:1-7` defines
  `ADL14DIR` and `adl14_archetype(file)`; every adl14 spec names its file
  explicitly. `grep -rn 'Dir\[\|Dir.glob' spec` finds **nothing** - no
  spec today iterates a directory. The conformance spec will be the first
  glob-driven example set, which is one reason to give it its own
  directory (`spec/conformance/`) rather than putting it under
  `spec/lib/openehr/adl_parser/`, whose files mirror `lib/`.
- Both runners collect `spec/**/*_spec.rb` unconditionally: `Rakefile:8`
  (`spec.pattern = FileList['spec/**/*_spec.rb']`) and plain
  `bundle exec rspec` (`.rspec` = `--require spec_helper` + `--colour`,
  no pattern override). CI runs `bundle exec rspec` with no extra env
  (`.github/workflows/ci.yml:24`). So the env-var gate must live *inside*
  the spec file; there is no runner-level exclusion to lean on.
- `spec/spec_helper.rb` starts SimpleCov (`:10-17`) and `require 'openehr'`
  (`:21`); the conformance spec needs nothing beyond that.

### (3) The reference corpus, as measured (not as the issue states it)

The issue says "36 under `sprint/adl/` at that repo's `b3bdb12`, plus one
per `archetypes/<id>/<id>.adl`". Measured:

- `b3bdb12` (2026-09-09, "Add CONTRIBUTING ...") contains **no
  `sprint/adl/` at all** - `git ls-tree -r --name-only b3bdb12 | grep
  '\.adl$'` lists only 4 `archetypes/<id>/{source,upload}/<id>.adl` pairs.
  `sprint/adl/` first appears at `c2ec655` (same day, "Add
  scripts/fetch_ckm.sh and the fetched sprint ADLs"). The "36 at b3bdb12"
  pin in the issue's AC2 is therefore not reproducible as written; this
  plan re-pins to a measured state (below) and the PR body will say so.
- At `82cf80b`: `sprint/adl/` holds **37** `*.adl` plus `manifest.tsv`
  (38 data rows; `openEHR-EHR-INSTRUCTION.service_request.v1` has a
  manifest row but no `.adl` file - a translation-repo bookkeeping
  detail, not ours to fix). `manifest.tsv` columns:
  `archetype_id cid status revision asset_version fetched_at` - **no
  sha256 column**.
- The per-archetype layout is now `archetypes/<id>/source/<id>.adl`
  (CKM original, "変更しない" per that repo's README) and
  `archetypes/<id>/upload/<id>.adl` (translated output) - 16 each. Of the
  16 `source/` files, 12 are byte-identical (`cmp`) to their `sprint/adl/`
  twin and **4 have no twin**: `COMPOSITION.request.v1`,
  `EVALUATION.reason_for_encounter.v1`, `INSTRUCTION.service_request.v1`,
  `SECTION.referral_details.v0`. So the CKM-original corpus is 37 + 4 =
  **41 distinct files**; `upload/` is out of scope (generating-tool
  output, not CKM output).
- Fetch procedure already exists there: `scripts/fetch_ckm.sh` -
  `BASE=https://ckm.openehr.org/ckm/rest/v1`, resolves `cid` via
  `/archetypes/citeable-identifier/<id>`, downloads
  `/archetypes/<cid>/adl` (with `?get-latest-published=true` for rows
  whose `targets.tsv` state starts with `published`) via `curl -o`, and
  rewrites `manifest.tsv`. Output is the raw CKM body (no
  post-processing), so a `sprint/adl/*.adl` file *is* the CKM download
  byte-for-byte at `fetched_at` - the same identity `spec/fixtures/ckm/
  README.md` documents for the three 2.4.3 fixtures.
- That repo's own CI (`.github/workflows/check.yml`) runs
  `tools/setup_openehr.sh` (clone + three patches, all now redundant at
  ≥ 2.4.3) and `make check` - a translation check, not a parser smoke; it
  doesn't replace #56.

### (4) Runtime budget (executed: this repo's `lib/` @ `237a34c`, rbenv Ruby 4.0.6, over `sprint/adl/*.adl` @ `82cf80b`)

`ADLParser.new(f).parse` per file, one process, no warm-up (executed
2026-09-20 via a scratch script outside the repo):

| | value |
| --- | --- |
| files | 37 |
| failures | 0 (all three 2.4.3 fixes hold on the live corpus) |
| total wall time | 276.6 s |
| median | ~2 s |
| slowest | `INSTRUCTION.medication_order.v3` 32.1 s (270 KB), `OBSERVATION.blood_pressure.v2` 26.2 s, `OBSERVATION.laboratory_test_result.v1` 25.6 s, `CLUSTER.symptom_sign.v2` 24.7 s, `EVALUATION.problem_diagnosis.v1` 24.4 s |

Runtime is roughly linear in file size (Treetop over the whole text). The
4 `source/`-only files are not in this measurement; extrapolating from
size puts the 41-file corpus at ~5-6 minutes on this machine. Consequences
for the design: (a) this must never run in the default suite - it would
multiply the suite's wall time several-fold; (b) a weekly scheduled job at
~6 min is well inside GitHub's limits and needs no parallelisation; (c)
the second serializer pass the issue lists as optional would roughly
double this, one more reason to leave it out of v1.

### (5) Semver / packaging

`openehr.gemspec:19-20` - `gem.files` is `git ls-files -- lib/*` plus
`README.rdoc`. Nothing in this change touches `lib/` or the gemspec, so it
is semver **neutral** (dev/test tooling only). `History.txt` has precedent
for recording such changes as `* Development: ...` lines (`History.txt:184`,
`:318`, `:373`, `:805`), so the entry goes into an unreleased section at the
top at merge time per `CLAUDE.md`.

### (6) RuboCop

`ci.yml`'s rubocop job lints `spec/` too (rubocop-rspec via
`.rubocop.yml:6-7`; `.rubocop_todo.yml` excludes are per-file, none cover
`spec/conformance/`). The new spec must be clean on `bundle exec rubocop`
- in particular `RSpec/DescribeClass` (describe a constant, not a bare
string) and the dynamic-example loop must not trip `RSpec/EmptyExampleGroup`
when the corpus dir is unset.

## Design

### Spec: `spec/conformance/ckm_corpus_spec.rb`

```ruby
# #56 - resolution shape (b) enhancement. Opt-in: set CKM_CORPUS_DIR to a
# directory of CKM ADL exports (see README.md next to this file for the
# pointer + fetch procedure). Unset -> one skipped example, so the default
# `bundle exec rspec` stays hermetic and offline.
RSpec.describe OpenEHR::Parser::ADLParser, 'CKM corpus conformance' do
  corpus_dir = ENV.fetch('CKM_CORPUS_DIR', nil)

  if corpus_dir.nil? || corpus_dir.empty?
    it 'parses every archetype of the CKM reference corpus' do
      skip 'set CKM_CORPUS_DIR=<dir of CKM *.adl exports> to run (see spec/conformance/README.md)'
    end
  else
    files = Dir[File.join(corpus_dir, '*.adl')].sort
    raise "CKM_CORPUS_DIR=#{corpus_dir}: no *.adl files" if files.empty?

    files.each do |file|
      it "parses #{File.basename(file)} without raising" do
        expect { described_class.new(file).parse }.not_to raise_error
      end
    end
  end
end
```

Decisions baked in:

- **One example per file**, not fail-on-first. The issue says "fails on
  the first ParseError/exception"; per-file examples are strictly more
  informative (one run lists every offending file, each failure names its
  file in the description) and cost nothing extra. Recorded here as a
  deliberate deviation.
- **Any exception, not just `ParseError`** - explore (1).
- **Empty corpus dir raises at load time** rather than passing vacuously:
  a misspelt path must not look like a green run.
- **Unset → exactly one pending example.** AC1's "example count and result
  are unchanged (skips only)" is read as: pass/fail counts unchanged, one
  pending added. The skip message carries the env-var name so `rspec`'s
  pending summary doubles as the discoverability hint.
- `validate: false` (default) - explore (1).
- No second pass through `ADLSerializer`/`XMLSerializer#merge` in v1 -
  the issue marks it optional, it doubles runtime, and no CKM-derived
  serializer failure is on record. Backlog entry, not scope.

### `spec/conformance/README.md` - pointer + fetch procedure

- What the corpus is: the CKM originals processed by
  skoba/openehr-japanese-translation - `sprint/adl/*.adl` (37 @
  `82cf80b`) and `archetypes/*/source/*.adl` (16, of which 4 are not in
  `sprint/adl/`), 41 distinct files. Pointer only; nothing copied.
- Two ways to populate `CKM_CORPUS_DIR`:
  1. **Pinned** (offline, reproducible): clone that repo at a commit,
     `cp sprint/adl/*.adl archetypes/*/source/*.adl "$CKM_CORPUS_DIR"/`
     (the 12 overlaps are byte-identical, so the copy is idempotent).
  2. **Live** (what the scheduled workflow does): same clone, then run
     its `scripts/fetch_ckm.sh` first so `sprint/adl/` is re-downloaded
     from the CKM REST API, then copy as above. This is the mode that
     surfaces a *new* CKM revision with a new construct.
- Byte-identity (AC4): `sprint/adl/<id>.adl` is `curl -o` of
  `GET $BASE/archetypes/<cid>/adl[?get-latest-published=true]` with no
  post-processing; `sha256sum` of the file equals `sha256sum` of a fresh
  `curl` of the same URL as long as the CKM revision hasn't moved
  (`manifest.tsv`'s `revision`/`asset_version` say which one you have).
  The three `spec/fixtures/ckm/` entries are the worked example, with
  their sha256s recorded in that README.
- Triage guidance for a red scheduled run: compare the failing file's
  `manifest.tsv` row (revision/asset_version) against the last green run;
  a moved revision means a new CKM construct → file an issue like
  #50/#51/#52 with the file as a **real** fixture; an unmoved revision
  means a parser regression on this side.

### Scheduled workflow: `.github/workflows/ckm-conformance.yml`

- Triggers: `schedule: cron '0 3 * * 1'` (weekly, Monday 03:00 UTC) and
  `workflow_dispatch` with a boolean input `fetch` (default `true`;
  `false` = pinned mode against the clone's committed `sprint/adl/`).
- `permissions: contents: read` (as `release.yml:13-14`).
- Single Ruby (4.0, `bundler-cache: true`), not the 3-way matrix: the
  grammar's acceptance of a construct doesn't vary by Ruby version, and
  the matrix is `ci.yml`'s job.
- Steps: checkout this repo → set up Ruby → `git clone --depth 1
  https://github.com/skoba/openehr-japanese-translation corpus-src` →
  (if `fetch`) `bash corpus-src/scripts/fetch_ckm.sh` → assemble
  `$RUNNER_TEMP/ckm-corpus` from `sprint/adl/*.adl` +
  `archetypes/*/source/*.adl` → `CKM_CORPUS_DIR=$RUNNER_TEMP/ckm-corpus
  bundle exec rspec spec/conformance/ckm_corpus_spec.rb` → on failure,
  upload `corpus-src/sprint/adl/manifest.tsv` as an artifact so the
  triage step above has the revision data even after the runner is gone.
- Deliberately **not** wired into `ci.yml`: a CKM-side change must show up
  as a scheduled failure to triage, never as a red check on an unrelated
  PR (issue's own requirement).
- Fetch failures (CKM down, REST change) fail at the `fetch_ckm.sh` step,
  so they are distinguishable from parser failures in the run log.

### Not in scope (backlog candidates)

- `rake conformance:fetch` - the README's two-command procedure is enough
  for v1 (issue: "a documented curl loop is enough").
- Serializer round-trip pass (above).
- Running the corpus `upload/` (translated) files - generating-tool
  output; if wanted, it belongs to the translation repo's `check.yml`.

## Red → green procedure (t-wada)

1. **Red (AC3, genuine):** create a scratch dir outside the repo with one
   syntactically broken `.adl` (e.g. the 2.4.3 person.v1 fixture with its
   `archetype` keyword removed) and one good one; run the spec with
   `CKM_CORPUS_DIR` pointing at it. Expect 1 failure whose description
   names the broken file and whose message shows `ParseError: Invalid
   ADL`. Record the output in `docs/reports/ckm-conformance-log.md`.
2. **Red (issue's AC2 witness):** `git worktree add /tmp/v242 v2.4.2`,
   copy the spec file in, run against the pinned 41-file corpus. Expect
   exactly the 4 failures the issue predicts (#50 `.v0` id, #51 empty
   slot ×2 - person.v1 and body_temperature.v2, #52 problem_diagnosis.v1).
   If the count differs, record what actually failed - don't adjust the
   prediction silently.
3. **Green:** same corpus on `master`, 41 examples pass. Record wall time
   (explore (4) predicts the order of magnitude).
4. **AC1:** `bundle exec rspec` with the var unset: same pass/fail counts
   as before, `1 pending`.
5. `bundle exec rubocop` clean.
6. `workflow_dispatch` the new workflow once after merge (both `fetch`
   modes) and record the run ids in the log; a workflow can't be
   exercised before it exists on `master`.

## Deliverables

- `spec/conformance/ckm_corpus_spec.rb`, `spec/conformance/README.md`
- `.github/workflows/ckm-conformance.yml`
- `History.txt`: unreleased section, one `* Development:` entry, semver
  neutral (explore (5))
- `docs/reports/ckm-conformance-log.md`: R8 with the red/green outputs
- `docs/backlog.md`: serializer pass + `rake conformance:fetch` as
  follow-ups
- Branch `feat/56-ckm-corpus-smoke`, PR `Fixes #56`, PR body states shape
  (b) and the corrected corpus pin (explore (3)).
