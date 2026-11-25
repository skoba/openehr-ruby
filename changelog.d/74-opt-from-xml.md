* OPTParser.from_xml(xml).parse parses OPT XML held in a String, with
  the same safe parse options (SAFE_PARSE_OPTIONS) as a path, so a
  caller no longer has to override #parse to read a document from memory.
  Called on a subclass, it returns an instance of that subclass. A
  leading UTF-8 BOM is accepted; an argument that is not a String raises
  ArgumentError. OPTParser.new(path).parse is unchanged. (#74)

Semver: minor. Adds a public class method; no signature change, no new
dependency.
