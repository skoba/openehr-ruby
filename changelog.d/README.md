# changelog.d

Change-log fragments, one per pull request. Introduced after the v2.5.0 tag
(see CLAUDE.md, 全開の進め方).

- A PR does not edit `History.txt`. It adds one file here instead:
  `changelog.d/<issue number>-<slug>.md`.
- The fragment holds the text that will go into `History.txt` as it stands
  (one `* ...` item, wrapped the way `History.txt` is, ending with the
  issue reference), followed by a `Semver:` line giving the call
  (patch / minor / major) and the reason.
- The record is still written at merge time. Only the place changed, so
  that open PRs no longer conflict on the same lines.
- At the release inventory the fragments are consolidated into a new
  section of `History.txt` and deleted. No fragment may remain in this
  directory at the tag. This README stays.

Example (`changelog.d/48-aql-time-hop.md`):

    * AQL: EVENT.time is now reachable from a path. ... (#48)

    Semver: patch. A query that raised now returns a value; no signature
    change.

Nothing in this directory ships in the gem (`openehr.gemspec` takes
`lib/*` and `README.rdoc` only).
