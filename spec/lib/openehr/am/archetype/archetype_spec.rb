require 'set'
require File.dirname(__FILE__) + '/../../adl_parser/parser_spec_helper'
describe OpenEHR::AM::Archetype::Archetype do
  let(:archetype) { adl14_archetype('openEHR-EHR-CLUSTER.anatomical_location.v1.adl') }

  it 'should be an instance of Archetype' do
    expect(archetype).to be_an_instance_of OpenEHR::AM::Archetype::Archetype
  end

  it 'adl_version should be assigned properly' do
    expect(archetype.adl_version).to eq('1.4')
  end
  
  it 'archetype_id should be assigned prorperly' do
    expect(archetype.archetype_id.value).to eq('openEHR-EHR-CLUSTER.anatomical_location.v1')
  end

  it 'should raise ArgumentError when archetype_id is nil' do
    expect { archetype.archetype_id = nil }.to raise_error ArgumentError
  end

  it 'uid should be assigned properly' do
    expect(archetype.uid.value).to eq('2fe9e9f8-adfd-4406-878a-82b38ef498a9')
  end

  it 'concept should be assigned properly' do
    expect(archetype.concept).to eq('at0000')
  end

  it 'should raise ArgumentError when concept is nil' do
    expect { archetype.concept = nil }.to raise_error ArgumentError
  end

  it 'parent_archetype_id should be assigned properly' do
    archetype.parent_archetype_id = OpenEHR::RM::Support::Identification::ArchetypeID.new(:value => 'openEHR-EHR-SECTION.physical_examination.v2')
    expect(archetype.parent_archetype_id.value).to eq('openEHR-EHR-SECTION.physical_examination.v2')
  end

  it 'definition should be assigned properly' do
    expect(archetype.definition.rm_type_name).to eq('CLUSTER')
  end

  it 'should raise ArgumentError when definition is nil' do
    expect {
      archetype.definition = nil
    }.to raise_error ArgumentError
  end
  
  it 'ontology should be assigned properly' do
    archetype.ontology = double("ontology", specialisation_depth: 1)
    expect(archetype.ontology.specialisation_depth).to be_equal 1
  end

  it 'should raise ArgumentError when ontology is nil' do
    expect { archetype.ontology = nil }.to raise_error ArgumentError
  end

  it 'invariants should be assigned properly' do
    archetype.invariants = double(Set, :size => 2)
    expect(archetype.invariants.size).to be_equal 2
  end

  it 'version should be extracted form id' do
    expect(archetype.version).to eq('v1')
  end

  it 'short concept name should be extracted from archetype id' do
    expect(archetype.short_concept_name).to eq('anatomical_location')
  end

  it 'concept name should be extracted from ontology' do
    expect(archetype.concept_name('en')).to eq('Anatomical location')
  end

  context 'to_rm'
end
