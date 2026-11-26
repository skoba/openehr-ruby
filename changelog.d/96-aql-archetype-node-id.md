* AQL: a LOCATABLE's archetype_node_id is now reachable from a path, so
  o/archetype_node_id works in SELECT and WHERE (e.g. WHERE
  o/archetype_node_id MATCHES {...} without an archetype predicate)
  instead of raising ExecutionError ("unsupported path attribute
  \"archetype_node_id\""). It is a row of TYPED_TERMINAL_HOPS under
  LOCATABLE, next to archetype_details and uid. (#96)

Semver: patch. A query that raised now returns a value; no new constant,
no signature change, no new dependency.
