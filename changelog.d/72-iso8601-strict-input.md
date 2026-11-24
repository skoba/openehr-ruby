* ISO8601DateTime and ISO8601Date (and so DV_DATE_TIME and DV_DATE) now
  reject input that is not exactly one ISO 8601 value. Their regular
  expressions were unanchored: "x2026-09-22T14zz" was accepted as
  2026-09-22T14, and ISO8601Date took the date out of a date-time
  String. ISO8601DateTime also accepted an hour without a complete date
  ("2026T14", which lost the hour) and misread the compact form
  ("20260922T143000" became year 0922); both now raise ArgumentError.
  The compact form is not supported. Complete values and the
  time-partial forms (YYYY-MM-DDThh, YYYY-MM-DDThh:mm) are unchanged.
  Upgrade note: code that relied on the old leniency - surrounding
  whitespace, a trailing newline, or passing a date-time String to
  ISO8601Date / DvDate - gets ArgumentError now. (#72)

Semver: patch. A bug fix, but it narrows accepted input; called out as
an upgrade note.
