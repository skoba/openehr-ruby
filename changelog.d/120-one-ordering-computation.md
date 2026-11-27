* ISO8601DateTime, ISO8601Date and DvDateTime now order by one
  computation, the calendar count of #117 (ISO8601DateModule#calendar_days
  and ISO8601DateTimeModule#utc_seconds, both protected). A missing
  month or day counts as 1 and a missing hour, minute or second as 0,
  inside that count only, as EHRbase does; values and strings keep
  their precision. The rule and its sources (RM Data Types 7.2, BASE
  Foundation Types 6.5, openEHR Discourse threads 11954 and 17524) are
  in the code comment and README. Behaviour change:
  - ISO8601DateTime and ISO8601Date counted a missing month or day as
    0, so 2026 ordered before 2026-01-01; it now orders the same (0),
    as DvDateTime already did;
  - ISO8601DateTime no longer inverts near the end of a 31-day month
    (2026-01-31T12:00:00Z now orders before 2026-02-01T00:00:00Z);
  - DvDate#magnitude no longer raises TypeError on a partial value
    (2026, 2026-11); it counts the earliest day.
  ISO8601DateModule#to_days is unchanged and is no longer used for
  ordering. (#120)

Semver: minor. Ordering results change for partial values and near
month ends, and DvDate partial values become comparable; no signature
change.
