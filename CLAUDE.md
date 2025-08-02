# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Ruby implementation of the openEHR specifications (v1.0.2), providing a comprehensive set of classes and modules for working with Electronic Health Records according to openEHR standards. The project includes ADL (Archetype Definition Language) parsing, Reference Model (RM) and Archetype Model (AM) implementations, and serialization capabilities.

## Development style

allways follow t-wada TDD policy.

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