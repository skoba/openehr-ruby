* AQL: in CONTAINS (A x OR B y), each branch's variables are now
  left-joined to the shared parent, so SELECT and WHERE may name a
  variable of a branch that did not match instead of raising
  SemanticError ("unbound variable"). A parent is kept when at least one
  branch matches; the unmatched branch's variables are null. When both
  branches match, one row holds both, and several matches in a branch
  multiply (2 x A and 3 x B give 6 rows, none null). A name not declared
  in FROM is still a SemanticError. The AQL specification (Release 1.1.0)
  does not decide what an unmatched branch returns; this follows EHRbase
  (left join, its "Simple 'AND' and 'OR'" conformance test) so that the
  same AQL returns the same rows. The question was raised upstream on
  2026-11-26:
  https://discourse.openehr.org/t/contains-a-or-b-what-should-an-unmatched-branch-return-a-third-implementation-asks-for-a-normative-answer/17523
  Behaviour change: a query that names only variables bound in every
  row (e.g. SELECT c) used to get one row per branch match (a parent
  with 1 A and 1 B gave 2 rows; 2 A and 3 B gave 5); it now gets one
  row per combination (1 and 6). Two branches that declare the same
  variable name keep the old union. (#97)

Semver: decided at the inventory (ruling R-20261126-10). A query that
raised now returns rows (patch), but the row count for a parent that
matches both branches changes, which is a behaviour change to weigh
(minor at least).
