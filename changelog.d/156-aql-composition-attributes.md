* AQL: COMPOSITION's category, language, territory and composer are now
  reachable from a path (c/category/value,
  c/category/defining_code/code_string, c/language/code_string,
  c/territory/code_string, c/composer/name,
  c/composer/external_ref/id/value). The names are reachable only on the
  RM type they belong to: an ENTRY's language and a DV_IDENTIFIER's id
  stay unreachable. (#156)

Semver: minor. New query paths become usable (an addition to what the
public AQL API accepts); a query that worked before returns the same
result. A path that raised "unsupported path attribute" on these names
now returns a value.
