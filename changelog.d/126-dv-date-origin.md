* DvDate#magnitude now counts days since 0001-01-01, as RM Data Types
  7.2.2 defines DV_DATE.magnitude, and returns an Integer. It uses the
  same count ISO8601Date orders by (#120). Behaviour change: every
  DvDate#magnitude number changes (2009-09-28 was 734045 and is now
  733677; it counted from 0000-01-01 on Ruby's default calendar and
  returned a Rational). The order of dates is unchanged. (#126)

Semver: minor. The public magnitude number changes for every value;
no signature change.
