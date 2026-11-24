* ISO8601DateTime and DV_DATE_TIME accept a date-time known only to the
  day, the month or the year: YYYY-MM-DD, YYYY-MM and YYYY (no "T" and
  no time part). The value is kept at the precision it was entered;
  no time of day is made up, and #value / #as_string / canonical JSON
  return it as given. This follows openEHR BASE Foundation Types
  section 6.2 ("Partial variants of Iso8601_date_time can include
  missing hours, days and months") and the Iso8601_date_time class
  description. It departs from that class's invariants
  (Partial_validity_hour: not hour_unknown, ...) and from
  valid_iso8601_date_time, which the specification also states; the
  specification is not consistent here.
  Ordering and equality: a missing part counts as the earliest value it
  could have (month 1, day 1, 00:00:00), so "2026-09-22" sorts before
  "2026-09-22T00:00:01". The time-partial forms (YYYY-MM-DDThh,
  YYYY-MM-DDThh:mm) now order the same way; comparing them raised
  TypeError before. == follows the ordering: "2026-09-22" ==
  "2026-09-22T00:00:00", while their #value differs.
  C_DATE_TIME#valid_value? accepts a date-only value when the
  constraint's hour validity allows a missing hour, and rejects it
  when the hour is mandatory. (#59)

Semver: minor. Values that raised ArgumentError are accepted; ordering
of partial values that raised TypeError now works. Complete values are
unchanged.
