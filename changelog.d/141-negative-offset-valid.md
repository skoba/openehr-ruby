* ISO8601Time.valid_iso8601_time? now accepts a negative UTC offset
  (14:30:00-05:00, 14:30-0500, 14:30:00-05). Before, it returned false
  for every negative offset, because it checked the signed offset hour
  against 0; ISO8601Time.new already read these times. An offset hour of
  24 or more, or minutes of 60 or more, is still rejected in either
  direction. (#141)

Semver: patch. A validity check that was wrong now agrees with the
parser; no signature change.
