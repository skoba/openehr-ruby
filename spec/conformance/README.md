# CKM corpus conformance smoke (#56)

`ckm_corpus_spec.rb` parses every `*.adl` file in the directory named by
`CKM_CORPUS_DIR` with `ADLParser` and fails, one example per file, on any
exception. It is **opt-in**: with the variable unset it contributes one
pending example and nothing else, so the default `bundle exec rspec` stays
hermetic and offline.

```sh
CKM_CORPUS_DIR=/path/to/ckm-corpus bundle exec rspec spec/conformance/ckm_corpus_spec.rb
```

Budget: the 41-file reference corpus takes ~5 minutes on a developer
machine (Treetop over up to 270 KB per file; the five largest files take
25-32 s each). Never wire this into the default suite.

## The corpus is a pointer, not a copy

The reference corpus is the set of CKM originals that
[skoba/openehr-japanese-translation](https://github.com/skoba/openehr-japanese-translation)
processes - the same files that surfaced #50, #51 and #52. Two locations
in that repository hold them:

- `sprint/adl/<id>.adl` - fetched by its `scripts/fetch_ckm.sh`;
  `sprint/adl/manifest.tsv` records `cid`, `status`, `revision`,
  `asset_version` and `fetched_at` per file.
- `archetypes/<id>/source/<id>.adl` - the untouched CKM original of each
  archetype that has entered translation. Most duplicate a `sprint/adl/`
  file byte-for-byte; a few exist only here.

Pinned reference (the state the spec was made green against): commit
`82cf80b`, 37 files under `sprint/adl/` plus 4 `source/`-only files
(`COMPOSITION.request.v1`, `EVALUATION.reason_for_encounter.v1`,
`INSTRUCTION.service_request.v1`, `SECTION.referral_details.v0`) - 41
distinct files. The corpus grows as that project's target set grows; the
scheduled job below follows its `HEAD`, not the pin.

## Populating `CKM_CORPUS_DIR`

**Pinned mode** (offline, reproducible - for reproducing a spec result):

```sh
git clone https://github.com/skoba/openehr-japanese-translation corpus-src
git -C corpus-src checkout 82cf80b            # or any later commit
mkdir -p ckm-corpus
cp corpus-src/sprint/adl/*.adl corpus-src/archetypes/*/source/*.adl ckm-corpus/
CKM_CORPUS_DIR=$PWD/ckm-corpus bundle exec rspec spec/conformance/ckm_corpus_spec.rb
```

The overlapping files are byte-identical, so the second `cp` is
idempotent.

**Live mode** (what the weekly workflow does): the same clone at `HEAD`,
then re-download `sprint/adl/` from the CKM before copying:

```sh
git clone --depth 1 https://github.com/skoba/openehr-japanese-translation corpus-src
(cd corpus-src && scripts/fetch_ckm.sh)       # every row of sprint/targets.tsv
mkdir -p ckm-corpus
cp corpus-src/sprint/adl/*.adl corpus-src/archetypes/*/source/*.adl ckm-corpus/
```

`fetch_ckm.sh` resolves each archetype id to its `cid` via
`GET https://ckm.openehr.org/ckm/rest/v1/archetypes/citeable-identifier/<id>`
and downloads `GET .../archetypes/<cid>/adl` (with
`?get-latest-published=true` for rows whose `targets.tsv` state starts
with `published`) using `curl -o`, with no post-processing. A file in
`sprint/adl/` is therefore the CKM download byte-for-byte as of its
`fetched_at`; `sha256sum` of the file equals `sha256sum` of a fresh `curl`
of the same URL for as long as the CKM revision has not moved
(`manifest.tsv`'s `revision`/`asset_version` say which one you have). The
three fixtures in `spec/fixtures/ckm/README.md` are the worked example,
with their sha256 values recorded.

## Scheduled workflow

`.github/workflows/ckm-conformance.yml` runs live mode weekly and on
`workflow_dispatch` (input `fetch`: `true` = live, `false` = pinned to the
clone's committed `sprint/adl/`). It is deliberately separate from the
PR-gating `ci.yml`: a CKM-side change must surface as a scheduled failure
to triage, never as a red check on an unrelated pull request. On failure
the run uploads `manifest.tsv` as an artifact so the revision data
survives the runner.

## When a run goes red

A red live run is the smoke doing its job - it means the CKM now emits a
construct this parser rejects - not a defect in the smoke. Triage:

1. Identify the failing file(s) from the example descriptions
   (`parses <file> without raising`). RSpec prints the exception class and
   message; for `ParseError: Invalid ADL` the grammar's failure position
   (`failure_reason`, line, column - printed by `ADLParser#parsed_data`)
   is on stdout immediately above the failure block.
2. Look up the file's row in the run's `manifest.tsv` artifact (or the
   clone's `sprint/adl/manifest.tsv`): `cid`, `revision`,
   `asset_version`, `fetched_at`. Compare with the last green run.
   - Revision moved: a new CKM construct. Expected as the corpus grows.
   - Revision unchanged: a parser regression on this side (bisect
     `master`).
3. File a parser issue in this repository, following the #50/#51/#52
   format: archetype id and `cid`, CKM revision, the offending ADL
   fragment with its line number, the exception class/message and (for
   grammar failures) Treetop's failure reason, and which grammar rule /
   helper rejects it. Resolution shape (a) bug; the file goes in
   `spec/fixtures/ckm/` as a **real** fixture (or **reduced** if it is
   large - `problem_diagnosis.v1.reduced.adl` is the precedent) with its
   sha256 added to that README's table.
4. Governing principle, unchanged from 2.4.3: the accepting parser is
   lenient toward what the CKM actually emits; strict validation is the
   generating tool's job.
