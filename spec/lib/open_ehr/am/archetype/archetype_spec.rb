require File.dirname(__FILE__) + '/../../../../spec_helper'
require 'set'
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::Ontology
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Common::Resource
include OpenEHR::RM::Support::Identification

describe Archetype do
  before(:each) do
    original_language = stub(CodePhrase, :code_string => 'ja')
    archetype_id = ArchetypeID.new(:value => 'openEHR-EHR-SECTION.physical_examination-prenatal.v2')
    definition = stub(CComplexObject, :rm_type_name => 'SECTION')
    items = {:text => 'Physical examination'}
    term1 = ArchetypeTerm.new(:code => 'at0000', :items => items)
    ontology = ArchetypeOntology.new(:specialisation_depth => 1, :term_definitions => {'ja' => {'at0000' =>term1}})
    uid = HierObjectID.new(:value => 'ABCD::1')
    parent_archetype_id = ArchetypeID.new(:value => 'openEHR-EHR-SECTION.physical_examination.v1')
    invariants = stub(Set, :size => 2)
    @archetype = Archetype.new(:original_language => original_language,
                               :adl_version => '1.4',
                               :archetype_id => archetype_id,
                               :concept => 'at0000',
                               :definition => definition,
                               :ontology => ontology,
                               :uid => uid,
                               :parent_archetype_id => parent_archetype_id,
                               :invariants => invariants)
  end

  it 'should be an instance of Archetype' do
    @archetype.should be_an_instance_of Archetype
  end

  it 'adl_version should be assigned properly' do
    @archetype.adl_version.should == '1.4'
  end
  
  it 'archetype_id should be assigned prorperly' do
    @archetype.archetype_id.value.should == 'openEHR-EHR-SECTION.physical_examination-prenatal.v2'
  end

  it 'should raise ArgumentError when archetype_id is nil' do
    lambda {
      @archetype.archetype_id = nil
    }.should raise_error ArgumentError
  end

  it 'uid should be assigned properly' do
    @archetype.uid.value.should == 'ABCD::1'
  end

  it 'concept should be assigned properly' do
    @archetype.concept.should == 'at0000'
  end

  it 'should raise ArgumentError when concept is nil' do
    lambda {
      @archetype.concept = nil
    }.should raise_error ArgumentError
  end

  it 'parent_archetype_id should be assigned properly' do
    @archetype.parent_archetype_id.value.should == 'openEHR-EHR-SECTION.physical_examination.v1'
  end

  it 'definition should be assigned properly' do
    @archetype.definition.rm_type_name.should == 'SECTION'
  end

  it 'should raise ArgumentError when definition is nil' do
    lambda {
      @archetype.definition = nil
    }.should raise_error ArgumentError
  end
  
  it 'ontology should be assigned properly' do
    @archetype.ontology.specialisation_depth.should be_equal 1
  end

  it 'should raise ArgumentError when ontology is nil' do
    lambda {
      @archetype.ontology = nil
    }.should raise_error ArgumentError
  end

  it 'invariants should be assigned properly' do
    @archetype.invariants.size.should be_equal 2
  end

  it 'version should be extracted form id' do
    @archetype.version.should == 'v2'
  end

  it 'short concept name should be extracted from archetype id' do
    @archetype.short_concept_name.should == 'physical_examination'
  end

  it 'concept name should be extracted from ontology' do
    @archetype.concept_name('ja').should == 'Physical examination'
  end
end
