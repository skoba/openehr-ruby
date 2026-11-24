* AQL: a COMPOSITION's context (EVENT_CONTEXT) is now queryable past the
  context hop itself. c/context/start_time/value, c/context/end_time/value
  and c/context/setting (.../value for the label,
  .../defining_code/code_string for the code) work in SELECT and WHERE
  instead of raising ExecutionError ("unsupported path attribute
  \"start_time\""). The three names are rows of TYPED_TERMINAL_HOPS,
  reachable on EVENT_CONTEXT only. A WHERE over start_time compares the
  ISO8601 text as a String, like EVENT.time. Other EVENT_CONTEXT
  attributes (location, health_care_facility, participations,
  other_context) still raise ExecutionError. (#71)

Semver: minor. New reachable paths; no signature change.
