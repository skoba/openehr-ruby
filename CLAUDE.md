# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Ruby implementation of the openEHR specifications (v1.0.2), providing a comprehensive set of classes and modules for working with Electronic Health Records according to openEHR standards. The project includes ADL (Archetype Definition Language) parsing, Reference Model (RM) and Archetype Model (AM) implementations, and serialization capabilities.

## Development style

allways follow t-wada TDD policy: write a failing spec first (red), make it
pass with the minimal change (green), then clean up (refactor). Do not
implement ahead of a red spec.

## Ticket-driven workflow

A change that touches the gem's runtime behavior, public API, or install-time
dependencies needs a GitHub Issue filed *before* work starts - no such
code-change commit without one. Docs-only, convention, and dev-tooling-only
changes don't require one (see the Release convention section below for the
same runtime-behavior/public-API/install-dependency test applied to semver).

- **Acceptance criteria must be spec-verifiable.** Write them as concrete,
  checkable conditions (a spec that exists and passes, an observable
  behavior), not vague intentions.
- **State which of three resolution shapes the change is**, in both the PR
  body and a spec comment:
  - **(a) bug** - a reproduction spec goes red first, then green (t-wada).
  - **(b) enhancement** - a spec for the new behavior goes red first, then
    green.
  - **(c) pin/hardening** - fixing an existing property that's already true
    (e.g. explicitly pinning a default that was already safe). Red is not
    achievable, and the spec must say so - literally write "regression pin"
    in a comment near the assertion. Don't fake a red phase to make it look
    like classic TDD when it isn't.
- **One issue = one branch = one PR** (see Contribution workflow below - this
  is the same rule, restated here because it's part of the ticket cycle).
  The PR closes the issue via `Fixes #N`.
- **A `docs/design/` plan document states its issue number at the top.**

## Contribution workflow

For any non-trivial change (bug fix, hardening, enhancement):

- **explore → plan → approval → implementation, in that order.** Read the
  actual source and cite `file:line` for every claim about existing
  behavior; do not guess at API shapes or call chains. Write the plan down
  (e.g. under `docs/design/`) before writing code, and get it approved
  before implementing.
- **Fixtures fall into four kinds; each fixture's leading comment must say
  which kind it is** (imported from openehr-rails' `CLAUDE.md`, which
  codified this first):
  - **real** — a genuine artifact (CKM export, Archetype Designer output, a
    real host-app template), used as-is.
  - **reduced** — a trimmed-down real artifact; the comment must name the
    real source it was reduced from.
  - **synthetic** — hand-authored, not derived from any real artifact.
    real/reduced are preferred by default; synthetic is only for structural
    test cases whose reproduction conditions can't be controlled with a real
    artifact. The leading comment must say it's synthetic and cite its
    design authority (e.g. a design doc section). Archetype IDs/at-codes
    should use self-evidently invented names that can't be mistaken for real
    ones — don't rename an existing fixture to fix this after the fact; its
    at-codes/archetype IDs are reference anchors other specs/docs already
    point to, and freezing those anchors takes priority.
  - **security** — built to exercise an attack/abuse case; the comment must
    say it is not a clinical artifact. Example already in this repo:
    `spec/lib/openehr/parser/security_fixtures/` (the XXE payloads from #33).
  - A fixture's provenance comment must describe its lineage as measured
    (checked against the actual design/implementation record), not as
    instructed — if an instructed lineage doesn't match what actually went
    into the fixture, write it to match reality instead.
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
- **Mixed-authorship commits get both trailers.** If Claude Code restructures
  or splits what Codex delivered - e.g. separating an unrelated fix that
  landed on the same lines into its own commit, which requires constructing
  an intermediate code state Codex never produced as a discrete unit - the
  resulting commit(s) carry both `Implemented-by: Codex` and
  `Restructured-by: Claude Code`. Don't give a commit a Codex-only trailer if
  it contains a code state Codex's delivery didn't.
- **Verify against the repo before recording a fact in it**, even when a
  prompt or an earlier report already stated it as true - a premise that
  went unverified once tends to get repeated, not corrected, if the next
  write also skips checking (e.g. "CI is unconfigured" repeated across two
  turns before anyone ran `gh run list`).
- **Repository boundary.** This session's work is scoped to this repository
  only. `cd` into another repository, or any read or execution there,
  requires the prompt to explicitly instruct crossing that boundary - and
  every such command's report must state the target repository (`pwd`/`git
  remote -v`) per command. If a prompt references something that doesn't
  exist in this repository, stop and ask before executing.
- **Distinguish executed from inferred.** State plainly in reports whether a
  claim was directly executed or inferred from other measurements. An
  inference must cite the measurement it rests on, and must never be
  reported as if it were executed.
- **Repository-context-dependent commands confirm their target explicitly.**
  A command whose target (repository, branch, or resumed session) is decided
  by ambient state - cwd, current branch, or session history - rather than an
  explicit argument, must have that target pinned before it runs; never
  assume the shell or session is still where an earlier step left it.
  - If the tool has an explicit target option, always use it: `git` takes a
    `cd` to the intended directory on the same command line (or `-C <path>`);
    `gh` takes `-R <owner>/<repo>` (or `--repo`) on every invocation.
  - If the tool has no such option (e.g. `codex exec`, `codex exec resume`),
    print `pwd` immediately before the call and confirm it names the intended
    repository first.
  - Before adopting a new repository-context-dependent command for the first
    time, decide how this principle applies to it before using it.

  (Generalized 2026-08-24, consolidating this repo's prior narrower
  branch-confirmation rule with `openehr-rails`'s repository-boundary rule,
  after a third incident of the same class surfaced the need for one shared
  principle covering non-git tools too. Three incidents on record: (1) this
  repo, 2026-08-23 - a docs-only commit intended for `master` landed on a
  checked-out PR feature branch instead, caught only because the follow-up
  `git push origin master` printed an anomalous "Everything up-to-date"; (2)
  `openehr-rails`, 2026-08-22 - a mistaken `checkout`/`pull` ran against the
  wrong repo, caught and self-reported immediately; (3) `anlage`, 2026-08-24 -
  `codex exec resume --last`, run after cwd had silently drifted back to this
  repo, resumed an unrelated stale session in the wrong repo instead of the
  intended one; Codex itself detected the mismatch and made no changes, so
  there was no lasting effect, but the near-miss is what prompted this
  generalization.)

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

A commit touching shipped runtime code (`lib/`, or anything else that ends up
in the built gem) is **at minimum patch, even when its observable behavior is
unchanged** - don't ship different code under the same version number.
"Neutral" is reserved for commits that don't touch shipped runtime code at all
(docs, CI, dev-tooling config, dev/test-group dependencies).

(This paragraph fixes the v2.3.2 release's `577a0d7` judgment call in the
rule — it touched `lib/openehr/parser.rb` et al. to make an already-safe
default explicit, proven bit-identical to the prior implicit behavior by its
own spec, and was still classified patch rather than neutral because it
shipped different code.)

(Added 2026-08-22, fixing the v2.3.1 release's `e728023` — a dev-tooling
commit unrelated to that release's actual fix — as the worked example of a
neutral classification under this rule.)

**A code change's `History.txt` entry is written at merge time**, into an
unreleased section at the top of the file (version number a placeholder,
finalized at tag time along with the semver call above). Don't defer the
entry itself to tag time — release-batching (which tag a change ships in)
and record-batching (when its `History.txt` line gets written) are separate
concerns; a change can wait for a release without its record waiting too.
(Added 2026-08-23, from PR #41 / #38, the worked example of an unreleased
section landing at merge time ahead of a deferred, batched release.)

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