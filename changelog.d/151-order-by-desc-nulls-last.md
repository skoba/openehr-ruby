* AQL: ORDER BY ... DESC now puts rows without the ordered value last, as
  ASC already did and as the engine's comment documents (NULLS LAST). DESC
  used to negate the comparison with the missing value too, so those rows
  came first; this has been the case since ORDER BY was added in 2.0.0.
  (#151)

Semver: patch (expected; decided at the inventory). A bug fix in how
existing queries order their rows; no signature change. A caller that
relied on DESC putting missing values first will see them last.
