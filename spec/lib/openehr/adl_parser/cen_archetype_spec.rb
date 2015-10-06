require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype
# ticket 25

describe 'parsing ISO 13606 archetypes' do
  let(:archetype) { adl14_archetype('CEN-EN13606-COMPOSITION.Controle.v2.adl') }

  it 'ADL parser parses ISO 13606 archetype' do
    expect(archetype).to be_an_instance_of Archetype
  end
end
