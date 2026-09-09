# CKM fixtures

Fixture kind: **real** — genuine openEHR CKM (https://ckm.openehr.org)
exports, used as-is. Each file is byte-identical to the CKM REST download
(`GET https://ckm.openehr.org/ckm/rest/v1/archetypes/<cid>/adl`,
`Accept: text/plain`); verify with `sha256sum`. The provenance lives here
rather than in a leading comment inside each file, because inserting a
comment would break the as-is identity with the CKM artifact. Files are
UTF-8 with BOM and CRLF line terminators; keep them unchanged.

Licence: the archetypes are openEHR Foundation works under CC BY-SA
(see each file's `["licence"]` entry).

| File | cid | CKM revision | Fetched | sha256 | Pins |
| --- | --- | --- | --- | --- | --- |
| `openEHR-EHR-EVALUATION.infectious_disease_summary.v0.adl` | 1013.1.1918 | 0.0.1-alpha | 2026-09-09 | `29d7768a517470ca0bcd5dac5a0d7e7115bbdea7fd3174b427d84cf45da8da13` | #50 — `.v0` archetype id |
