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
| `openEHR-EHR-CLUSTER.person.v1.adl` | 1013.1.5358 | 1.0.5 | 2026-09-09 | `69cc7845b3f4491102d32750c884bdda2593c42c869c14afeed17cd2e5c3b056` | #51 — empty "any archetype" slot (`CLUSTER[at0008]`) |
| `openEHR-EHR-EVALUATION.problem_diagnosis.v1.reduced.adl` | 1013.1.169 | 1.7.4 | 2026-09-09 | (reduced — see below; source sha256 `8462a3b811a440c2b01451f0da48c7d297d53b5dc4d45c4722b13321e645ce1f`) | #52 — empty `author = < >` in the `["fi"]` translation |

## Reduced fixture

`openEHR-EHR-EVALUATION.problem_diagnosis.v1.reduced.adl` — fixture kind:
**reduced**. Source: the CKM export of `openEHR-EHR-EVALUATION.problem_diagnosis.v1`
(cid 1013.1.169, revision 1.7.4, fetched 2026-09-09, sha256
`8462a3b811a440c2b01451f0da48c7d297d53b5dc4d45c4722b13321e645ce1f`,
262,313 bytes, 3,025 lines). The full export takes ~34 s per
`ADLParser#parse` (Treetop over 262 KB), too slow for the suite, so it was
cut down by line range from the CR-stripped, BOM-stripped original:

- lines 1-140 verbatim — `archetype` header, `concept`, the whole
  `language` section (all 15 translations, including the `["fi"]` block
  with the empty `author = < >` that #52 pins) and `description` up to
  `details = <`;
- lines 355-396 — the `["en"]` `details` entry only (the other 14
  language entries are dropped);
- lines 764-903 — the rest of `description` (`lifecycle_state`,
  `other_contributors`, `other_details` incl. `["revision"]`) and the whole
  `definition`;
- lines 905-906, 1303-1438, 3025 — `ontology` / `term_definitions` with the
  `["en"]` terms only (the other 15 language term sets are dropped).

Nothing was edited inside the kept lines. The ADL grammar does not accept a
comment before `archetype` (measured), so this provenance note lives here.
Parses in ~5 s.
