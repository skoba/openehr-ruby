# Plan: ArchetypeID/TerminologyID drop their canonical `value` from JSON (#46, #32 pathology, 3rd instance)

## Context

[#46](https://github.com/skoba/openehr-ruby/issues/46): anlage found
(`issue9-log` R2, blocking `skoba/anlage#9`) that `ArchetypeID` and
`TerminologyID` never emit a `value` key when serialized via
`RMJSONSerializer`, even on openehr 2.4.1 (confirmed after bumping — not a
stale pre-2.4.1 report). This is the same root-cause *shape* as #32's
`ObjectVersionID` bug (fixed by PR #39), just in two sibling `ObjectID`
subtypes #32 didn't check at the time.

## Explore results (verified against master @ `59f5948`)

### (1) Compared against PR #39's `ObjectVersionID` fix pattern

`ObjectID#value=` (`identification.rb:15-18`) sets `@value = value` in the
base class. `ArchetypeID#value=` (`:70-81`) and `TerminologyID#value=`
(`:172-181`) both **override without calling `super`**, decomposing into
component ivars instead — exactly `ObjectVersionID`'s pre-#39 shape. Their
`value` getters (`ArchetypeID#value` `:95-98`, `TerminologyID#value`
`:163-169`) are **computed** (not `attr_reader`), so the Ruby-level
`.value` call still works correctly — only the *serialized JSON* is
missing the key, since `RMJSONSerializer` reflects on `instance_variables`
directly, not method calls.

### (2) Exhaustive sweep of the same pathology

`grep -rln 'def value=' lib/openehr/rm/ lib/openehr/am/` found 11 files;
every `value=` implementation was read. Result: **`ArchetypeID` and
`TerminologyID` are the only two classes** with this exact pathology
(computed getter + non-`super`, non-`@value`-storing setter). Everything
else already sets `@value` directly or via `super`: `UID`/`UIDBasedID`/
`ObjectVersionID`, `DvDate`/`DvTime`/`DvDateTime`/`DvDuration` (already
covered by #32's `EXCLUDED_IVARS`), `DvText`, `DvUri`/`DvEhrUri`,
`DvOrdinal`/`DvScale`, `Timezone`, `ValidityKind`, `OperatorKind`,
`CDvState`, `DvTimeSpecification` and its subclasses.

**`VersionTreeID`/`KNOWN_DERIVED_CACHE_TYPES` relationship, clarified**:
`VersionTreeID#value=` (`:343-349`) has a related-but-different quirk — its
getter (`:351-356`) reassigns `@value` as a side effect on every call (not
real memoization), so `@value` may or may not be present depending on
unrelated call history. This is **out of scope** here: nothing canonically
needs a `value` key from `VersionTreeID`'s own JSON shape (consumers use
`trunk_version`/`branch_number`/`branch_version` directly — even
`ObjectVersionID#value` itself interpolates `@version_tree_id.value` in
Ruby code, never reads it from JSON), and if `@value` *does* leak into
output, `KNOWN_DERIVED_CACHE_TYPES` (`factory.rb:23`) already tolerates an
unrecognized `value` key for `VERSION_TREE_ID` on read. `ArchetypeID`/
`TerminologyID` have the opposite problem — a *missing*, not
possibly-redundant, key — and neither needs adding to
`KNOWN_DERIVED_CACHE_TYPES`: both already have working `Factory` classes
(`ArchetypeIdFactory`, `TerminologyIdFactory`, `factory.rb:329-345`), so
there's no `NameError` for that mechanism to catch. This fix is purely
about what gets *written*.

### (3) Watchdog gap, confirmed

`spec/lib/openehr/rm/support/identification/archetype_id_spec.rb`
extensively asserts the Ruby-level `.value` getter (which round-trips
correctly regardless of this bug, since it's computed from ivars either
way) but never serializes through `RMJSONSerializer`. `factory_spec.rb`'s
`ArchetypeID` examples only assert `be_an_instance_of(ArchetypeID)` —
existence, not a JSON value round-trip. Same gap class #32 closed for
`ObjectVersionID` specifically, not generalized to sibling types.

### (4) Compatibility: old-JSON read-back, verified empirically

```
$ bundle exec ruby -e '...'
Ruby-level .value: "openEHR-EHR-SECTION.physical_examination.v2"
Serialized JSON: {"_type":"ARCHETYPE_ID","rm_originator":"openEHR",...}  # no "value" key (today's output)
value key present? false
Restored via decomposed-keys JSON, .value: "openEHR-EHR-SECTION.physical_examination.v2"
```

Reading today's (decomposed-only) JSON back through `Factory.create`
already reconstructs `.value` correctly — `ArchetypeID#initialize`/
`TerminologyID#initialize` branch on `args[:value].nil?` and fall back to
individual setters. New-shape (`value`-only) JSON already works too, since
that's how these objects are normally built (`Factory.create('ARCHETYPE_ID',
value: ...)` → `super(args)` → base `value=`). **Both directions are
unaffected by this fix** — it changes only what's written; `Factory`'s read
path never consults `EXCLUDED_IVARS`. Matches the task's own expectation
("スカラー無視の既存挙動で現状維持のはず").

## Decision

Mirror #32/PR #39's `ObjectVersionID` pattern exactly, for both classes:

1. `ArchetypeID#value=` and `TerminologyID#value=` each add `@value = value`
   (storing the canonical string directly; the decomposition stays, since
   `qualified_rm_entity`/`domain_concept`/etc. still need the individual
   fields for their own logic).
2. Add to `RMJSONSerializer::EXCLUDED_IVARS`: `ArchetypeID`'s
   `:@rm_originator, :@rm_name, :@rm_entity, :@concept_name,
   :@specialisation, :@version_id` and `TerminologyID`'s `:@name` (note:
   `:@version_id` is shared by name with `ArchetypeID`'s own decomposed
   ivar — one entry covers both, they're the same symbol).
3. New watchdog spec(s): each identifier class's JSON `value` key
   round-trips, structurally closing off a fourth recurrence in any other
   `ObjectID` subtype the same way #32 intended but didn't generalize.

## TDD cycles (t-wada; resolution shape: bug, red-first, per Ticket-driven
workflow)

1. **Cycle 1 (red)**: a spec serializing `ArchetypeID.new(value: ...)` and
   `TerminologyID.new(value: ...)` via `RMJSONSerializer`, asserting the
   parsed JSON's `"value"` key equals the original string, for both.
   Confirmed red today (both currently omit the key).
2. **Cycle 2 (green, minimal)**: implement the Decision above for both
   classes. Confirm Cycle 1 goes green.
3. **Cycle 3 (regression pin — already true, not staged as fake-red)**: a
   spec confirming both old-shape (decomposed-keys-only) and new-shape
   (`value`-only) JSON read back correctly via `Factory.create` for both
   `ArchetypeID` and `TerminologyID` — four assertions. This property is
   **already true before this fix** (verified in finding (4)), so per this
   repo's Ticket-driven workflow rule it must be written and labeled
   "regression pin" in a spec comment, not staged as red-first.
4. **Cycle 4 (regression)**: full `bundle exec rspec` run, particularly
   `archetype_id_spec.rb`, `factory_spec.rb`'s `ArchetypeIdFactory`/
   `TerminologyIdFactory` examples, and anything serializing an
   `Archetyped`/ontology object that embeds either identifier type.
5. **Cycle 5 (refactor)**: none anticipated; the change mirrors an
   already-established pattern exactly.

## Compatibility note (History.txt draft, added at merge time)

```
* RMJSONSerializer now emits the canonical "value" key for ArchetypeID
  and TerminologyID (both OBJECT_ID subtypes) instead of only their
  internal decomposed fields (rm_originator/rm_name/rm_entity/
  concept_name/specialisation/version_id for ArchetypeID; name/
  version_id for TerminologyID) - the same class of gap #32 fixed for
  ObjectVersionID, generalized to these two sibling types. Reading back
  JSON persisted by a prior version of this gem (decomposed keys only,
  no "value") is unaffected - Factory already reconstructs both types
  from their individual fields when "value" is absent. (#46)
```

## Acceptance criteria mapping (from the filed issue)

- "A spec asserts... includes a `value` key matching the original
  string" (both types) → Cycle 1/2.
- "Existing... specs remain green" → Cycle 4.
- "Reading back both old-shape and new-shape JSON... covered by a spec" →
  Cycle 3.

## Semver

**Patch (placeholder, confirmed at Step 6 inventory)**: touches shipped
runtime code (`lib/openehr/rm/support/identification.rb`,
`lib/openehr/serializer/rm_json_serializer.rb`) — observable-but-corrective,
same class as #40. No public API signature change (no new required
argument, no removed method), no install-dependency change.
