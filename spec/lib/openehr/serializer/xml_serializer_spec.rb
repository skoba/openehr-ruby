require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/sample_archetype_spec'
require 'rexml/document'
include OpenEHR::Serializer

describe XMLSerializer do

  before(:all) do
    current_dir = File.dirname(__FILE__)
    xml_file = File.open(current_dir + '/openEHR-EHR-SECTION.test.v1.xml')
    xml = xml_file.readlines
    class << xml
      def unindent(s,e,num)
        self[s..e].collect{|line| line[num..-1]}.join
      end
    end
    @sample_header = xml.unindent(2, 11, 2)
    @sample_description = xml.unindent(12, 27, 2)
    @sample_definition = xml.unindent(28, 39, 2)
    @sample_ontology = xml.unindent(40, 58, 2)
    @sample_xml = xml.join
    xml_file.close
    @archetype = sample_archetype
  end

  before(:each) do
    @xml_serializer = XMLSerializer.new(@archetype)
  end

  it 'should be an instance of XMLSerializer' do
    @xml_serializer.should be_an_instance_of XMLSerializer
  end

  it 'should return XML formatted header' do
    @xml_serializer.header.should == @sample_header
  end

  it 'should return XML formatted description' do
    @xml_serializer.description.should == @sample_description
  end

  it 'should return XML formatted definition' do
    @xml_serializer.definition.should == @sample_definition
  end

  it 'should return XML formatted ontology' do
    @xml_serializer.ontology.should == @sample_ontology
  end
end
