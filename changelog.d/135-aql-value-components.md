* AQL: .../value of a DV_DATE_TIME or DV_DATE (c/context/start_time/value)
  now compares in WHERE and orders in ORDER BY like the value itself
  (#134, #161): by the written components, equal down to the common
  precision, offsets applied only when both sides have one; ORDER BY by
  earliest instant, the coarser value first on a tie. Before, it was a
  String comparison. SELECT, LIKE and MATCHES still see the String as
  written. A literal that is not an ISO 8601 date or date-time compared
  with such a .../value now raises ExecutionError. README.rdoc (and its
  Japanese translation) describes the rule, its examples and how it
  differs from EHRbase. Upgrade note: results change where the stored
  values or the literal differ in offset or precision, for example
  2026-03-01T08:00:00+09:00 no longer matches .../value >=
  '2026-03-01T00:00:00Z', 2026-03-15 now matches .../value >=
  '2026-03-15T00:00:00Z', .../value = '2025' matches every value in
  2025, and ORDER BY .../value follows the instant instead of the text.
  To compare the stored text itself, use LIKE without wildcards. (#135)

Semver: minor (expected; decided at the inventory). Results of existing
queries change on .../value, and an unreadable literal now raises; no
signature change.
