* ISO8601Date and ISO8601DateTime (and so DvDate and DvDateTime) now
  read the ISO 8601 compact form BASE Foundation Types 6.5.1 lists:
  YYYYMMDD and YYYYMM for a date; YYYYMMDDThhmmss[(,|.)s+][Z|+hhmm],
  YYYYMMDDThhmm, YYYYMMDDThh, YYYYMMDD and YYYYMM for a date-time. They
  give the same fields, order and as_string as the extended form;
  as_string is always the extended form (6.5.4, 6.5.6), while a DV_
  value keeps the string it was given. A value that mixes the two forms
  (2026-09-22T143000, 20260922T14:30:00) is still rejected. Behaviour
  change: is_extended? now says which form was given (false for a
  compact value) instead of always true; a value that cannot show a
  separator (2026, 14) counts as extended. Compact times were already
  read. (#80)

Semver: minor. More input is accepted (it raised ArgumentError since
#72), and is_extended? returns false for compact values; no signature
change.
