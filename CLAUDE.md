# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Ruby implementation of the openEHR specifications (v1.0.2), providing a comprehensive set of classes and modules for working with Electronic Health Records according to openEHR standards. The project includes ADL (Archetype Definition Language) parsing, Reference Model (RM) and Archetype Model (AM) implementations, and serialization capabilities.

## Development style

allways follow t-wada TDD policy: write a failing spec first (red), make it
pass with the minimal change (green), then clean up (refactor). Do not
implement ahead of a red spec.

## Contribution workflow

For any non-trivial change (bug fix, hardening, enhancement):

- **explore → plan → approval → implementation, in that order.** Read the
  actual source and cite `file:line` for every claim about existing
  behavior; do not guess at API shapes or call chains. Write the plan down
  (e.g. under `docs/design/`) before writing code, and get it approved
  before implementing.
- **Fixtures come from real artifacts.** A spec fixture (ADL, OPT/XML, JSON)
  should be derived from an actual openEHR artifact (a real archetype/
  template, or output from a real tool), condensed if needed, with its
  provenance noted in a comment. The one exception is a fixture built
  specifically to exercise a security control (e.g. XXE) - note that
  exception explicitly in the fixture itself.
- **One issue = one branch = one PR.** Don't bundle unrelated fixes.
- **Every change needs a semver call and a `History.txt` entry.** State
  whether the change is patch/minor/major and why, even if the answer is
  debatable - record the reasoning, not just the conclusion.
- **Don't commit scratch/tmp scripts.** One-off verification scripts used
  while working belong in a scratch directory outside the repo, not in the
  commit.
- **Codex delivers working-tree changes only.** It does not commit. Claude
  Code reviews the diff against the approved plan first, then makes the
  commit(s) with a trailer identifying the source (e.g.
  `Implemented-by: Codex`).

## Release convention

Before tagging, make the final semver determination from the actual content
accumulated since the previous tag (`git diff <previous-tag>..master`), not
from a pre-assigned version number. If the instructed version number
contradicts the actual content, stop instead of tagging and ask for
re-arbitration.

To do this, classify every commit since the previous tag. A commit is semver
**neutral** only if it affects none of: the gem's runtime behavior, its public
API, or its install-time dependencies (the gemspec's runtime dependencies,
`required_ruby_version`, and `files`). Docs, CI/dev-tooling config, and
dev/test-group dependency additions are the common neutral cases — but judge
each commit on what it actually touches, not on which of these categories it
superficially resembles. If a commit's classification is genuinely unclear,
that is itself a reason to stop instead of tagging and ask for re-arbitration,
the same as a content/instructed-version mismatch.

(Added 2026-08-22, fixing the v2.3.1 release's `e728023` — a dev-tooling
commit unrelated to that release's actual fix — as the worked example of a
neutral classification under this rule.)

## Development Commands

### Testing
- `bundle exec rspec` - Run all tests
- `bundle exec rspec spec/path/to/specific_spec.rb` - Run specific test file
- `bundle exec rake spec` - Run tests via Rake (default task)
- `bundle exec guard` - Start Guard for continuous testing during development

### Linting and Code Quality
- `bundle exec rubocop` - Run RuboCop linter
- `bundle exec rake rubocop` - Run RuboCop via Rake

### Dependencies
- `bundle install` - Install gem dependencies
- `bundle update` - Update dependencies

### Building/Packaging
- `bundle exec rake build` - Build the gem
- `bundle exec rake install` - Install the gem locally
- `bundle exec rake release` - Release the gem (if authorized)

## Architecture

### Core Module Structure

The codebase follows the openEHR specification with three main architectural layers:

1. **Reference Model (RM)** (`lib/openehr/rm/`)
   - Support Information Model - Basic identification, measurement services
   - Data Types - Basic types, text, quantities, date/time, encapsulated data, URIs
   - Data Structures - Item structures, history management
   - Common Information Model - Archetyped classes, generic components, change control
   - EHR Information Model - Composition, content, entries
   - Demographic Information Model - Patient and provider demographics
   - Integration Information Model - External system integration

2. **Archetype Model (AM)** (`lib/openehr/am/`)
   - Archetype Object Model - Core archetype definitions and constraints
   - openEHR Archetype Profile - Specialized data type constraints
   - Template Object Model - Operational templates

3. **Parser/Serializer** (`lib/openehr/parser/`, `lib/openehr/serializer.rb`)
   - ADL Parser - Parses Archetype Definition Language files
   - OPT Parser - Parses Operational Template files
   - XML/JSON serializers for various formats

### Key Components

- **ADL Parser** (`lib/openehr/parser/adl_parser.rb`) - Uses Treetop grammar to parse ADL files
- **Factory Pattern** (`lib/openehr/rm/factory.rb`) - Creates RM instances from parsed data
- **Assumed Library Types** (`lib/openehr/assumed_library_types.rb`) - Basic data types like intervals, ISO8601 dates/times

### Entry Point
The main entry point is `lib/openehr.rb` which requires all necessary modules in dependency order.

## Testing Strategy

The project uses RSpec for testing with comprehensive test coverage:
- Unit tests for all major classes
- ADL parsing tests using real-world archetype files
- Test files are organized to mirror the lib/ structure
- Guard is configured for continuous testing during development

## Dependencies

Key runtime dependencies:
- `treetop` - For ADL grammar parsing
- `nokogiri` - XML processing
- `activesupport` - Rails utilities
- `builder` - XML building
- `xml-simple` - Simple XML parsing

Development dependencies include RSpec, Guard, RuboCop, and SimpleCov for testing and code quality.

## Working with ADL Files

ADL (Archetype Definition Language) test files are located in `spec/lib/openehr/adl_parser/adl14/`. These represent real openEHR archetypes and can be used for testing parser functionality. The grammar file is at `lib/openehr/parser/adl_grammar.tt`.

## Serialization

The project supports multiple serialization formats including ADL, XML, and JSON through the serializer module, though some serializers are still in development.