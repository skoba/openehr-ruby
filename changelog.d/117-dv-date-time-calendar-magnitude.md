* DvDateTime#magnitude is now the number of seconds since
  0001-01-01T00:00:00Z on the (proleptic Gregorian) calendar, as RM Data
  Types 7.2 defines it. Before, a year counted as 365.24 days and a
  month as 30.42 days, so a 31-day month overlapped the next one and
  order inverted near its end: 2026-01-31T12:00:00Z compared after
  2026-02-01T00:00:00Z. What changes when upgrading:
  - every DvDateTime#magnitude number changes (2009-09-29T15:03:22.3Z
    was 63423697018.3 and is now 63389833402.3);
  - <=>, sorting and == follow the calendar order;
  - AQL ORDER BY on .../time or .../time/magnitude, and WHERE on
    .../time/magnitude, now order by the instant (string comparison of
    .../time/value is unchanged);
  - diff, add and subtract give the same results as before. (diff on a
    month-end pair still raises, a separate bug: #118.)
  A missing month or day still counts as 1, and a missing hour, minute
  or second as 0, for ordering only. (#117)

Semver: at least minor; the final call is made at the inventory. The
ordering is a bug fix, but the public magnitude number changes for every
value, so a caller that stored or compared raw magnitudes sees
different numbers.
