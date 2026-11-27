* DvTime#magnitude and ISO8601Time#<=> now say in their comments that
  times with different UTC offsets compare as written (the offset is
  ignored), because a time has no date and normalising it to UTC can
  cross midnight. Regression pins fix the current behaviour. No
  behaviour change. (#113)

Semver: patch. Comments only in lib/, which ships different code under
a new version; behaviour is unchanged.
