require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Ontology
include OpenEHR::RM::DataTypes::Text

describe ArchetypeOntology do
  before(:each) do
    items = {:text => 'Archetype Concept', :desc => 'concept description'}
    term1 = ArchetypeTerm.new(:code => 'at0000', :items => items)
    items = {:text => 'Blood pressure'}
    term2 = ArchetypeTerm.new(:code => 'at0001', :items => items)
    term_definitions = {'ja' => [term1, term2]}
    items = {:text => 'test', :description => 'test item'}
    term3 = ArchetypeTerm.new(:code => 'ac0000', :items => items)
    constraint_definitions = {'ja' => [term3]}
    code_phrase = stub(CodePhrase, :code_string => '163020007')
    bind = {'at0000' => code_phrase}
    term_bindings = {'SNOMED-CT(2003)' => [bind]}
    @archetype_ontology =
      ArchetypeOntology.new(:term_definitions => term_definitions,
                            :constraint_definitions => constraint_definitions,
                            :term_bindings => term_bindings,
                            :specialisation_depth => 0)
  end

  it 'should be an instance of ArchetypeOntology' do
    @archetype_ontology.should be_an_instance_of ArchetypeOntology
  end

  it 'specialisation depth should be assigned properly' do
    @archetype_ontology.specialisation_depth.should be_equal 0
  end

  it 'term_definitions should be assigned properly' do
    @archetype_ontology.term_definitions(:lang => 'ja', :code => 'at0000')[:text].should == 'Archetype Concept'
  end

  it 'term_codes should returnd all at codes' do
    @archetype_ontology.term_codes.should == ['at0000','at0001']
  end

  it 'constraint_definitions should be assigned properly' do
    @archetype_ontology.constraint_definitions(:lang => 'ja', :code => 'ac0000')[:text].
      should == 'test'
  end

  it 'constrant_codes should return all ac codes' do
    @archetype_ontology.constraint_codes.should == ['ac0000']
  end

  it 'term_bindings should be assigned properly' do
    @archetype_ontology.term_bindings['SNOMED-CT(2003)'][0]['at0000'].
      code_string.should == '163020007'
  end

  it 'terminologies_available should return available terminology' do
    @archetype_ontology.terminologies_available.should == ['SNOMED-CT(2003)']
  end
end
                            
