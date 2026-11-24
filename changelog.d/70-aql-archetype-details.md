* AQL: a COMPOSITION's archetype_details is now reachable from a path, so
  c/archetype_details/template_id/value (and .../archetype_id/value)
  works in SELECT and WHERE instead of raising ExecutionError
  ("unsupported path attribute \"archetype_details\""). A root without
  archetype_details gives a null column. PathEvaluator's whitelist
  gained a per-type table, TYPED_TERMINAL_HOPS, next to the generic
  names in ALLOWED_TERMINAL_HOPS: a typed name is reachable only on the
  RM type it belongs to (archetype_details on LOCATABLE; archetype_id
  and template_id on ARCHETYPED). Still a whitelist read through
  public_send. One error changed type: a generic name asked of a value
  that has no such reader (e.g. c/name/magnitude) now raises
  OpenEHR::AQL::ExecutionError with the usual "unsupported path
  attribute" message, where NoMethodError used to leak. (#70)

Semver: minor. New reachable paths; no signature change. The
NoMethodError -> ExecutionError change only affects queries that already
failed.
