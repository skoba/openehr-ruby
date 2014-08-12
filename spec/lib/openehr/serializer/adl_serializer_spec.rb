require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/sample_archetype_spec'
include OpenEHR::Serializer
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::Ontology
include OpenEHR::RM::Support::Identification

describe ADLSerializer do

  before(:all) do
    current_dir = File.dirname(__FILE__)
    adl_file = File.open(current_dir + '/openEHR-EHR-SECTION.test.v1.adl')
    adl = adl_file.readlines
    @sample_header = adl[0..7].join
    @sample_description = adl[9..22].join
    @sample_definition = adl[24..25].join
    @sample_ontology = adl[27..37].join
    @sample_total = adl.join
    adl_file.close
    @archetype = sample_archetype
    @adl_serializer = ADLSerializer.new(@archetype)
  end

  it 'should be an instance of ADLSerializer' do
    expect(@adl_serializer).to be_an_instance_of ADLSerializer
  end

  it 'header should return archetype context' do
    expect(@adl_serializer.header).to eq(@sample_header)
  end

  it 'description should return archetype description' do
    expect(@adl_serializer.description).to eq(@sample_description)
  end

  it 'definition should return ADL formatted definition' do
    expect(@adl_serializer.definition).to eq(@sample_definition)
  end

  it 'ontology should return ADL formatted ontology' do
    expect(@adl_serializer.ontology).to eq(@sample_ontology)
  end

  it 'should return serialized ADL format' do
    expect(@adl_serializer.serialize).to eq(@sample_total)
  end
end
