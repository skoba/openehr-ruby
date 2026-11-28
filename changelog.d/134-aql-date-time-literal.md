* AQL: a DV_DATE_TIME or DV_DATE path can now be compared with a quoted
  ISO 8601 date or date-time literal, a parameter, or another such path,
  as AQL (QUERY 3.12.5) writes it: WHERE c/context/start_time >=
  '2026-01-01'. Before, this raised NoMethodError. The two compare by
  their written components, from the year on, only those both sides have
  (#161): 2026-11 > '2026-10-30', and values equal down to the common
  precision are equal, so 2026-11 = '2026-11-15' and = '2025' matches
  every value in 2025. Offsets are applied only when both sides have one;
  otherwise values compare as written (2026-03-01T08:00:00+09:00 >=
  '2026-03-01' matches). A DV_DATE compares with a date-time literal by
  its date. ORDER BY on these values orders by earliest instant, the
  coarser value first on a tie. The specification gives no rule for
  partial values or mixed offsets; this rule differs from EHRbase, which
  fills missing components and reads a missing offset as UTC. A literal
  that cannot be read as a date or date-time (not ISO 8601, a time only,
  a number) raises ExecutionError instead of matching nothing. The RM
  types' own <=> and magnitude are unchanged. (#134, #161)

Semver: minor (to be confirmed at the inventory). Queries that raised
now return rows; ORDER BY ties now have a fixed order; no signature
change. #161 changed the unreleased #134 behavior before release.
