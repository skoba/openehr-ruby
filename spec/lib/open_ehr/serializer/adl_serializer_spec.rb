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
    @adl_serializer.should be_an_instance_of ADLSerializer
  end

  it 'header should return archetype context' do
    @adl_serializer.header.should == @sample_header
  end

  it 'description should return archetype description' do
    @adl_serializer.description.should == @sample_description
  end

  it 'definition should return ADL formatted definition' do
    @adl_serializer.definition.should == @sample_definition
  end

  it 'ontology should return ADL formatted ontology' do
    @adl_serializer.ontology.should == @sample_ontology
  end

  it 'should return serialized ADL format' do
    @adl_serializer.serialize.should == @sample_total
  end
end
