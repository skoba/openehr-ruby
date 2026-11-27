* Docs: README.ja.rdoc, a Japanese translation of README.rdoc. README.rdoc
  links to it at the top and it links back; the English version wins where
  they differ. The Japanese file is not in the gem. (#145)

Semver: patch. README.rdoc ships in the gem (openehr.gemspec takes it by
name) and gains one navigation line, so the built gem's bytes change; the
round 2 and round 3 logs classified README.rdoc-only commits as patch for
the same reason. No runtime behavior, API or dependency changes. If this
is the only change at the next inventory, it alone does not call for a
release.
