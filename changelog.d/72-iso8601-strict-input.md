* Behaviour change: ISO8601DateTime and ISO8601Date (and so DV_DATE_TIME
  and DV_DATE) now reject input that is not exactly one ISO 8601 value.
  Their regular expressions were unanchored, so such input used to be
  accepted with part of it silently dropped or misread. Four kinds of
  input raise ArgumentError now:
  - surrounding characters, including leading/trailing whitespace and a
    trailing newline ("x2026-09-22T14zz" used to be read as
    2026-09-22T14). The caller must trim.
  - a date-time String given to ISO8601Date / DvDate ("2026-09-22T10:00:00"
    used to be read as 2026-09-22, dropping the time).
  - an hour without a complete date ("2026T14", "2026-09T14" used to be
    read as 2026 and 2026-09, dropping the hour).
  - the compact form ("20260922T143000" used to be misread as year
    0922). The compact form is valid ISO 8601 and valid in openEHR; it
    is rejected for now rather than read wrongly, and reading it
    correctly is tracked separately.
  Complete values and the time-partial forms (YYYY-MM-DDThh,
  YYYY-MM-DDThh:mm) are unchanged. (#72)

Semver: patch. A bug fix (values were silently altered), but it narrows
accepted input, so it is recorded as a behaviour change.
