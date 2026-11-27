* AQL: a DV_DATE_TIME or DV_DATE path can now be compared with a quoted
  ISO 8601 literal or a parameter, as AQL (QUERY 3.12.5) writes it:
  WHERE c/context/start_time >= '2026-01-01'. Before, this raised
  NoMethodError. The literal is read as the path's type (extended or
  compact form, partial values) and the two are compared by instant,
  with the ordering count of #117/#120: a partial value is its earliest
  instant and a value without an offset is UTC (the specification gives
  no rule for either; this follows EHRbase). = and != compare instants
  too. A literal that cannot be read as the path's type (not ISO 8601,
  a time-only literal against a DV_DATE_TIME, a date-time literal
  against a DV_DATE, a number) raises ExecutionError instead of
  matching nothing. Queries that already ran give the same results;
  comparisons of .../value stay String comparisons (#135). (#134)

Semver: minor (to be confirmed at the inventory). Queries that raised
now return rows; no signature change.
