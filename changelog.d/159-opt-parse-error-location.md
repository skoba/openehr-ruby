* OPTParser#parse now raises OpenEHR::Parser::ParseError when the XML is
  broken and the parse fails: the message gives the line, column and text
  of the first error libxml2 recorded, and the original exception's class
  and message; the original exception is the cause. The XML is still read
  with RECOVER (#36), so a document whose errors do not stop the parse
  (a "--" in a comment) still parses, and a document with no XML error
  raises what it raised before. Upgrade note: such input raised
  ArgumentError (usually "invalid archetype id form") before; a caller
  that rescues ArgumentError by name for it now needs ParseError (both
  are StandardError). (#159)

Semver: minor (per R-20261128-12). Only input that already failed
changes, but the exception class a caller may rescue changes.
