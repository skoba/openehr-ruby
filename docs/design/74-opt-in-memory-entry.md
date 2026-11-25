# #74 OPTParser: OPT XML held in memory — plan

Issue: #74. Refs R-20261125-4 (work item 3). Resolution shape **(b) enhancement**.
Planned in `docs/design/round3-plan.md` section 7, row 6, as an addition only. That plan did not decide the API shape; this document does.

## Existing behaviour (read)

- `OPTParser#parse` reads only from a path:
  `File.open(@filename) { |file| Nokogiri::XML::Document.parse(file, options: SAFE_PARSE_OPTIONS) }` (`lib/openehr/parser/opt_parser.rb:42-45`).
- `Base#initialize(filename)` stores the path, and `attr_reader :filename` exposes it (`lib/openehr/parser.rb:32-36`).
- `SAFE_PARSE_OPTIONS` is `RECOVER | NONET | BIG_LINES` (`lib/openehr/parser.rb:26-30`).
- The downstream consumer (openehr-rails `lib/openehr_rails/opt/parser.rb:12-37`, read only) handles this as follows:
  - It subclasses `OPTParser` and overrides `#parse`.
  - It sniffs the one argument to `new` to decide whether it holds a path or raw XML.
  - It calls `Nokogiri::XML::Document.parse(source)` with **no options**, so it does not inherit `SAFE_PARSE_OPTIONS`.
  - It copies the construction of the `OperationalTemplate`.

## API shape

```ruby
OpenEHR::Parser::OPTParser.from_xml(xml_string).parse   # new
OpenEHR::Parser::OPTParser.new(path).parse              # unchanged
```

- `from_xml` is a class method that returns a parser instance, not a template. The call reads the same way as `new(path).parse`.
- `from_xml` builds the instance with `new`. A subclass therefore gets an instance of the subclass, with its own overrides. For example, `OpenehrRails::Opt::Parser.from_xml(xml)` is an `OpenehrRails::Opt::Parser`.
- A non-String argument raises `ArgumentError`. For an instance made this way, `filename` is `nil`.
- **Rejected: sniffing the content of `new`'s one argument.** A path and a document become ambiguous. The issue asks to avoid this.
- **Rejected: a keyword on `new`, `new(nil, xml: ...)`.** It changes `Base#initialize`'s signature for every parser, and it reads worse than `from_xml`.
- **Out of scope:** `XMLArchetypeParser` gets no in-memory entry. No caller has asked for one.

## Implementation

- `#parse` gets the document from one private method, `read_document`:
  - If XML was given, it calls `Nokogiri::XML::Document.parse(@xml, options: SAFE_PARSE_OPTIONS)`.
  - Otherwise it uses the existing `File.open` block, unchanged.
- The rest of `#parse`, the construction of the template, is shared by both paths.
- A UTF-8 BOM at the head of the String needs no code. Nokogiri accepts it, in both a binary String and a UTF-8 String (executed against `minimum_template.opt`).

## Collision sweep

Names this change adds: the class method `from_xml`, the instance variable `@xml` and the private method `read_document`.

- Measured with `grep -rn` over `lib/` and `spec/`, there are no other occurrences of `from_xml`, `read_document` or `@xml`.
- The names do not appear in the modules that `OPTParser` includes (`XMLConstraintParsing`, `XMLPrimitiveParsing`, `XMLDomainTypeParsing`).
- No cross-class registry is involved. A parser instance is never serialized, so no excluded-ivar list applies.

## Specs (red first)

All of the following go in `spec/lib/openehr/opt_parser/opt_parser_from_xml_spec.rb`:

1. `from_xml(File.read(path)).parse` gives a template equal in content to `new(path).parse`. This compares the template id, uid, concept, the definition's `archetype_id`, the set of paths, and the `component_terminologies` keys. It is checked for `minimum_template.opt` and `eReferral.opt`.
2. Safe options:
   - `Nokogiri::XML::Document.parse` is called with `options: SAFE_PARSE_OPTIONS`. This follows the existing pattern in `xxe_safety_spec.rb`.
   - An end-to-end check: the spec builds an OPT String whose `<concept>` holds an external entity that points at `security_fixtures/xxe_sentinel.txt`. The parsed template's concept does not contain the sentinel marker.
   - The entity is built inside the spec from `minimum_template.opt` (a real fixture) and the security fixture's sentinel. No new file is added.
3. A String that starts with a UTF-8 BOM parses to the same template id.
4. A subclass's `from_xml` returns an instance of the subclass.
5. A non-String argument raises `ArgumentError`.
6. `new(path).parse` is unchanged. This is a **regression pin**: the existing OPT specs and the full suite stay green.

## Semver

**Minor.** It adds a public class method. No signature changes and no dependency changes.

## After this

#36 (STRICT as default) can reach downstream once openehr-rails drops its override and moves to `from_xml`. That is downstream work. Here it is a note for the #36 gate report.
