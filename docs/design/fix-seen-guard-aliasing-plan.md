# Plan: RMJSONSerializer's seen-guard misidentifies aliasing as cycles (#40)

## Context

[#40](https://github.com/skoba/openehr-ruby/issues/40): `RMJSONSerializer`'s
`seen` guard (`lib/openehr/serializer/rm_json_serializer.rb`) permanently
marks an object as "seen" the first time it's encountered and never
un-marks it. This correctly stops a true cycle, but also fires for
non-cyclic **aliasing** — two different attributes on the same object
pointing at the *identical* sub-object — silently emitting `null` for the
second occurrence instead of the sub-object's real value.

## Explore results (verified against master @ `00c394d`)

### (a) Cycle inventory: what remains after `@parent` exclusion?

Both genuine back-reference families in the codebase are named `@parent`,
and both are already fully covered by `EXCLUDED_IVARS`'s single `:@parent`
entry (exclusion is by ivar symbol, not by class):

- **RM side** (`PATHABLE`): `Pathable` (`lib/openehr/rm/common/archetyped.rb:21-22`)
  declares `attr_accessor :parent`; `Locatable < Pathable` (`:151`) inherits
  it. Actively built by `Composition#content=` (`composition.rb:61`),
  `History#events=` (`data_structures/history.rb:41`),
  `Cluster#items=` (`data_structures/item_structure/representation.rb:71`),
  and `Pathable#initialize` for any directly-`Pathable` class given a
  `:parent` arg. Genuinely dereferenced at runtime, not inert:
  `Event#offset` reads `@parent.origin` (`history.rb:73`).
- **AOM side** (`ArchetypeConstraint`): independently declares its own
  `attr_accessor :parent` (`am/archetype/constraint_model.rb:5-11`,
  `initialize` sets it from `args[:parent]`), built by
  `CAttribute#children=` (`:200-202`) and `CComplexObject#attributes=`
  (`:296-298`). Also dereferenced at runtime (`congruent?`'s
  `path.index(@parent.path)`, `:26`).
- A broad search (`@owner`, `@container`, `@composition`, any `= self`
  assignment) across all of `lib/openehr/` found **no other back-reference
  ivar family** anywhere. (One coincidental, irrelevant hit:
  `OpenEHR::AQL::Model::Containment` also has an ivar literally named
  `@parent`, but no RM/AOM class ever holds a `Containment` instance, so
  it's unreachable from anything `RMJSONSerializer` is asked to serialize.)

**Implication**: there is currently **no genuine, reachable cycle** in the
RM/AOM object graph — both families that could form one are already
excluded. A stack-based guard's true-cycle-catching behavior therefore
cannot be exercised against any *real* class today; it would be
defense-in-depth for a case that isn't presently live, not a fix for an
observable gap. **Cycle 2 below must use a synthetic object graph** — no
real artifact can demonstrate a currently-reachable cycle (four-kind
fixture taxonomy: synthetic, design authority = this plan's finding (a)).

### (b) Other aliasing cases beyond `ObjectVersionID`

- `ObjectVersionID#value=` (`lib/openehr/rm/support/identification.rb:247-258`)
  still sets `@root = @oid` internally (line 253) — **#32 did not remove the
  aliasing**, it only added `@root`/`@oid`/etc. to `EXCLUDED_IVARS`
  (`rm_json_serializer.rb:26-27`), which masks the *symptom* from JSON
  output without touching the underlying object identity. Not currently
  observable via `RMJSONSerializer` — matches #40's own prior note.
- **New finding, independently reproduced twice** (once via exploration,
  once directly, below): `OperationalTemplate#template_id=`
  (`lib/openehr/am/template.rb:31-38`) sets **both** `@template_id` and
  `@archetype_id` to the identical passed-in object:

  ```ruby
  def template_id=(template_id)
    if template_id.nil?
      raise ArgumentError, 'template_id is mandatory for operational template'
    end
    @template_id = template_id
    # Update archetype_id to match template_id for consistency
    @archetype_id = template_id if template_id
  end
  ```

  Neither `@template_id` nor `@archetype_id` is in `EXCLUDED_IVARS` — this
  case is **not masked**, and is reproducible today:

  ```
  $ bundle exec ruby -e '
  require "openehr"
  template_id = OpenEHR::RM::Support::Identification::TemplateID.new(value: "1234567890")
  opt = OpenEHR::AM::Template::OperationalTemplate.allocate
  opt.send(:template_id=, template_id)
  puts "template_id.equal?(archetype_id): #{opt.template_id.equal?(opt.archetype_id)}"
  seen = Set.new.compare_by_identity
  serializer = OpenEHR::Serializer::RMJSONSerializer.new(opt)
  puts serializer.send(:object_value, opt.template_id, seen).inspect
  puts serializer.send(:object_value, opt.archetype_id, seen).inspect
  '
  template_id.equal?(archetype_id): true
  {"_type"=>"TEMPLATE_ID", "value"=>"1234567890"}
  nil
  ```

**Implication — changes #40's own prior assumption**: #40's issue body
says the "Suggested test" needs "a synthetic two-attributes-alias-one-object
fixture as its primary path, not a fallback to one," written when
`ObjectVersionID` was the only known case and #32 was about to exclude it.
That's now stale: `OperationalTemplate` is a real, already-shipped,
already-tested RM/AM class that reproduces this bug today, unmasked. Per
this repo's fixture taxonomy ("real/reduced are preferred by default;
synthetic is only for structural test cases whose reproduction conditions
can't be controlled with a real artifact") — **recommending `OperationalTemplate`
as Cycle 0's real reproduction case instead of a synthetic double-reference
fixture.** Flagged as the one substantive decision point for gate approval
below; a synthetic fixture is only needed for Cycle 2 (the true-cycle
regression pin), not for Cycle 0.

### (c) Impact scope of the in-progress-stack fix

Proposed mechanism: `object_value` pushes `value` into `seen` before
recursing (as today), then **pops it** (`seen.delete(value)`) right before
returning the built hash — narrowing `seen`'s meaning from "ever
encountered" to "currently being recursed into." The existing `return nil
if seen.include?(value)` check is unchanged, so true-cycle behavior
(returns `nil` for the cyclic back-reference) is preserved exactly.

Verified in isolation (a standalone script, not touching real source — see
this plan's git history / session transcript for the exact script) against
both target behaviors:

- **Aliasing** (two parents, one shared child): both occurrences serialize
  the child's real value — the child is popped after the first occurrence
  finishes, so it's no longer "seen" by the time the second is reached.
- **True cycle** (A → B → A): still correctly caught at the innermost
  level — A is still in `seen` (not yet popped, since we're still inside
  its own recursion) when B's reference back to A is reached. No
  `SystemStackError`, no infinite loop.

**Existing-spec risk, checked**: `rm_json_serializer_spec.rb`'s "excludes
the parent back-reference, avoiding infinite recursion" example
(`:92-99`) does **not** exercise the `seen` guard's cycle-catching behavior
at all — `@parent` is filtered out of `instance_variables` by
`EXCLUDED_IVARS` before any recursion into it happens, so this spec passes
purely via exclusion, never reaching the `seen.include?` check for that
link. Confirms (again, independently of finding (a)) that no existing spec
provides real coverage of the guard's cycle-catching behavior — which is
exactly why Cycle 2 below has to be new and synthetic, not a
straightforward "make sure the existing spec stays green" check.

## Decision

Implement the push-on-enter/pop-on-exit shape in `object_value`. No change
to `EXCLUDED_IVARS` — `OperationalTemplate`'s aliasing being *observable*
(not masked) is what makes it usable as Cycle 0's red spec; excluding it
would defeat that.

## TDD cycles (t-wada; issue #40 is labeled `bug` → resolution shape (a),
red-first, per this repo's Ticket-driven workflow)

1. **Cycle 1 (regression pin, written first — safety net before touching
   the mechanism)**: a synthetic two-node object graph with a genuine
   mutual back-reference (A ↔ B), asserting serialization completes
   without raising and without exceeding a bounded recursion depth, and
   that the cyclic link itself resolves to `nil` (matching today's
   behavior). This is **already green today** (current code already
   handles true cycles correctly — that was never the bug) — per the
   Ticket-driven workflow's resolution-shape rule, this must be written and
   labeled **"regression pin"** in a spec comment, not staged as fake red.
   Confirms the fix doesn't reintroduce infinite recursion before Cycle 2
   makes any change.
2. **Cycle 2 (red)**: `OperationalTemplate` built with a real `TemplateID`,
   serialized via `RMJSONSerializer`; asserts `archetype_id`'s serialized
   value is *not* `null` and matches `template_id`'s own serialized value.
   Red today (confirmed above — `archetype_id` currently serializes to
   `null`).
3. **Cycle 3 (green, minimal)**: implement the push/pop change in
   `object_value`. Confirm Cycle 2 goes green and Cycle 1 stays green.
4. **Cycle 4 (regression)**: full `bundle exec rspec` run — particularly
   `rm_json_serializer_spec.rb`'s existing round-trip and `@parent`-exclusion
   examples, and anything exercising `OpenEHR::AQL::ResultSet`/`opt_serializer.rb`
   (both call `RMJSONSerializer`/`JSONSerializer` directly, per the earlier
   cycle-inventory sweep).
5. **Cycle 5 (refactor)**: none anticipated beyond Cycles 1-4; the change
   is small and self-contained.

## Compatibility note (History.txt draft, added at merge time per this
repo's own convention)

```
* RMJSONSerializer's cycle guard now only treats an object as "seen"
  while it's actively being recursed into (pushed on entry, popped on
  exit) rather than permanently once first encountered. Two different
  attributes on the same object that alias the same sub-object (e.g.
  OperationalTemplate#template_id=, which sets both template_id and
  archetype_id to the identical object) now both serialize that
  sub-object's real value; previously the second occurrence silently
  serialized as null. Genuine cycles (e.g. PATHABLE's @parent, already
  excluded from traversal separately) are still caught correctly - this
  only narrows what counts as "seen", it does not remove the guard.
  Observable change: any output containing a previously-nulled aliased
  attribute will now contain that attribute's real value instead. (#40)
```

## Acceptance criteria mapping (from #40)

- "A spec exists asserting that when two attributes... reference an
  identical sub-object..., `RMJSONSerializer` serializes both attributes
  with the sub-object's real value, not `null`." → Cycle 2.
- "Existing cycle-guard behavior... remains covered by a regression spec
  and stays green." → Cycle 1 (written first, explicitly as a regression
  pin) + Cycle 4's full-suite check.

## Open question for gate approval

Use `OperationalTemplate` (real, already-shipped class) as Cycle 2's
reproduction case instead of the synthetic fixture #40's own issue body
assumed would be needed? Recommended yes, per the reasoning in finding (b)
above and this repo's real-preferred fixture taxonomy.
