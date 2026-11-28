* as_string of ISO8601Time, ISO8601DateTime, DvTime and DvDateTime now
  writes the UTC offset in the extended form, as BASE Foundation Types
  6.5.5-6.5.6 says as_string does: 14:30:00+0900 is written as
  14:30:00+09:00. Z, ±hh:mm and ±hh are written as before. #timezone and
  a DV_ value keep the offset as given. ISO8601Timezone#as_string is
  unchanged. Behaviour change: callers that compared as_string output
  with a +hhmm offset see +hh:mm. (#138)

Semver: patch or minor, decided at the inventory. Output of as_string
changes for a compact offset; no signature change.
