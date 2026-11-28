* ISO8601Time (and so DvTime) now rejects a time that mixes the
  extended and compact forms, such as 1430:00 or 14:3000, and
  valid_iso8601_time? returns false for it. BASE Foundation Types
  6.5.1 lists times in one form only; ISO8601Date and ISO8601DateTime
  already rejected mixed forms (#80).
  Upgrade note: such times were accepted before (read as 14:30:00) and
  now raise ArgumentError. Write them as 14:30:00 or 143000. (#136)

Semver: patch or minor, decided at the inventory. Input outside the
specification is no longer accepted; no signature change.
