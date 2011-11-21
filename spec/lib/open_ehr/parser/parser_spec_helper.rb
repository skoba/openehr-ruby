ADL14DIR = File.dirname(__FILE__) + '/adl14/'
include OpenEHR::Parser

def adl14_archetype(file)
  ap = ADLParser.new(ADL14DIR + file)
  ap.parse
end
