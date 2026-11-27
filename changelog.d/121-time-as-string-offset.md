* ISO8601Time#as_string (and DvTime#as_string) now writes the UTC
  offset whatever the precision. Before, it was written only after a
  fractional second, so 10:30:15+09:00 came back as 10:30:15. #value
  and the JSON serializer already kept it. (#121)

Semver: patch. A lost part of the value is no longer dropped; no
signature change. Callers inside the gem (DvDateTime#diff,
History) use ISO8601DateTime#as_string and are not affected.
