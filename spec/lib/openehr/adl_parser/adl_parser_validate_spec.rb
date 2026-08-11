require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe 'OpenEHR::Parser::ADLParser#parse(validate:)' do
  def parser_for(file)
    OpenEHR::Parser::ADLParser.new(ADL14DIR + file)
  end

  it 'does not validate by default (existing behaviour preserved)' do
    archetype = parser_for('openEHR-EHR-CLUSTER.anatomical_location.v1.adl').parse
    expect(archetype).to be_an_instance_of OpenEHR::AM::Archetype::Archetype
  end

  it 'returns the archetype when validate: true and it is structurally valid' do
    archetype = parser_for('openEHR-EHR-CLUSTER.anatomical_location.v1.adl').parse(validate: true)
    expect(archetype).to be_an_instance_of OpenEHR::AM::Archetype::Archetype
  end

  it 'raises the first validation violation when validate: true and the archetype is not valid' do
    ap = parser_for('openEHR-EHR-CLUSTER.anatomical_location.v1.adl')
    error = OpenEHR::Parser::Exception::Validation::VATDF.new('boom')
    validator = double('validator')
    allow(validator).to receive(:validate!).and_raise(error)
    allow(OpenEHR::Parser::ArchetypeValidator).to receive(:new).and_return(validator)

    expect { ap.parse(validate: true) }.to raise_error(error)
  end
end
