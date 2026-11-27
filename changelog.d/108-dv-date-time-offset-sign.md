* DvDateTime#magnitude now normalises to UTC by subtracting the offset,
  so 2026-03-01T10:00:00+09:00 has the magnitude of 01:00Z and orders
  before 11:00Z. Before, a positive offset was added instead (the value
  came out 18 hours late for +09:00), a negative offset's minutes went
  the wrong way (-03:30 counted as -02:30), and "-00:30" was right only
  by accident. AQL WHERE and ORDER BY on DV_DATE_TIME values with a
  non-UTC offset compared them wrongly. Values without an offset, Z
  values and whole-hour negative offsets are unchanged. DvTime,
  ISO8601Time and ISO8601DateTime still compare local fields without
  the offset (unchanged here). (#108)

Semver: patch. A wrong result is corrected; no signature change, no new
public method, no new dependency.
