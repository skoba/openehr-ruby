* An hour-only UTC offset (±hh, e.g. 2026-03-01T10:00:00+09,
  20260301T100000+09, 14:30:00+09) is now read by Timezone,
  ISO8601Time, ISO8601DateTime (extended and compact) and so the DV_
  classes, as BASE Foundation Types 6.5.1 lists it (Z|±hh[:mm],
  Z|±hh[mm]). Before, it raised ArgumentError. It counts whole hours
  where the offset becomes seconds, so +09 orders and has the magnitude
  of +09:00, and -00 counts as 0. (#137)

Semver: minor (to be confirmed at the inventory). More input is
accepted; no signature change.
