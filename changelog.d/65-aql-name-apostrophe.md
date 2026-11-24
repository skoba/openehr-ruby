* AQL: a name predicate value containing an apostrophe (e.g.
  items[at0001, "O'Brien"] or items[openEHR-EHR-CLUSTER.x.v1, "O'Brien"])
  no longer raises OpenEHR::Path::InvalidPathError from a SELECT/WHERE
  path. PathEvaluator used to write the predicate back into PATHABLE
  path text, whose quoting cannot hold an apostrophe; it now asks
  PATHABLE for the node id alone and narrows by name itself, with the
  same rule (name.value equals the given name). OpenEHR::Path's own
  grammar is unchanged: a path String with an apostrophe inside a
  quoted name is still invalid there. (#65)

Semver: patch. A query that raised now returns a value; results of
queries that worked are unchanged.
