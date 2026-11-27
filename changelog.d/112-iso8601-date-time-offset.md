* ISO8601DateTime#<=> now compares the UTC instant, by the same rule
  as DvDateTime#magnitude (#108): local time minus the offset, with Z
  and a value without an offset both read as UTC. Before, it compared
  the written local time and ignored the offset, so
  2026-03-01T10:00:00+09:00 ordered after 2026-03-01T02:00:00Z, the
  opposite of DvDateTime. The offset helper moved from DvDateTime into
  ISO8601DateTimeModule (private), so both classes use one rule. (#112)

Semver: patch. A wrong ordering is corrected; no signature change, and
values without an offset (or all in Z) order as before.
