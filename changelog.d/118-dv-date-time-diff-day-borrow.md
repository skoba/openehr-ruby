* DvDateTime#diff no longer raises "Day is not valid" when the later
  value is on the 1st of a month and earlier in the day than the other
  value (2026-01-31T12:00:00Z to 2026-02-01T00:00:00Z now gives
  P0Y0M0W0DT12H0M0S). The borrowed day is taken on the calendar
  instead of by setting day - 1. (#118)

Semver: patch. A call that raised now returns a value; no signature
change.
