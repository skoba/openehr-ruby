* AQL: a LOCATABLE's uid is now reachable from a path, so c/uid/value
  works in SELECT and WHERE instead of raising ExecutionError
  ("unsupported path attribute \"uid\" on a ...Composition"). A
  composition without a uid gives a null column. uid is a row of
  TYPED_TERMINAL_HOPS under LOCATABLE, not a generic name, so it stays
  unreachable on VERSION and VERSIONED_OBJECT, which also have a uid.
  (#88)

Semver: patch. A query that raised now returns a value; no new constant,
no signature change, no new dependency.
