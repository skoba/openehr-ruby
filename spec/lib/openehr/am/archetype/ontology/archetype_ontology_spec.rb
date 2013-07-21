require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Ontology
include OpenEHR::RM::DataTypes::Text

describe ArchetypeOntology do
  before(:each) do
    items = {'text' => 'Archetype Concept', 'desc' => 'concept description'}
    term1 = {'at0000' => ArchetypeTerm.new(:code => 'at0000', :items => items)}
    items = {'text' => 'Blood pressure'}
    term2 = {'at0001' => ArchetypeTerm.new(:code => 'at0001', :items => items)}
    term_definitions = {'ja' => (term1.update term2), 'en' => term1}
    items = {'text' => 'test', 'description' => 'test item'}
    term4 = {'ac0003' => ArchetypeTerm.new(:code => 'ac0003', :items => items)}
    constraint_definitions = {'ja' => term4}
    code_phrase = double(CodePhrase, :code_string => '163020007')
    bind = {'at0000' => code_phrase}
    term_bindings = {'SNOMED-CT(2003)' => bind}
    @archetype_ontology =
      ArchetypeOntology.new(:primary_language => "ja",
                            :languages_available => ['ja', 'en'],
                            :terminologies_available => ['SNOMED-CT(2003)'],
                            :term_definitions => term_definitions,
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

  it 'primary language is ja' do
    @archetype_ontology.primary_language.should == 'ja'
  end

  it 'languages available are ja, en' do
    @archetype_ontology.languages_available.should == ['ja', 'en']
  end

  it 'term_definition should be assigned properly' do
    @archetype_ontology.term_definition(:lang => 'ja', :code => 'at0000').items['text'].should == 'Archetype Concept'
  end

  it 'term_codes should returnd all at codes' do
    @archetype_ontology.term_codes.should == ['at0000','at0001']
  end

  it 'constraint_definitions should be assigned properly' do
    @archetype_ontology.constraint_definition(:lang => 'ja', :code => 'ac0003').items['text'].
      should == 'test'
  end

  it 'constrant_codes should return all ac codes' do
    @archetype_ontology.constraint_codes.should == ['ac0003']
  end

  it 'term_bindings should be assigned properly' do
    @archetype_ontology.term_bindings['SNOMED-CT(2003)']['at0000'].
      code_string.should == '163020007'
  end

  it 'terminologies_available should return available terminology' do
    @archetype_ontology.terminologies_available.should == ['SNOMED-CT(2003)']
  end

  it 'has language ja' do
    @archetype_ontology.should have_language 'ja'
  end

  it 'has language en' do
    @archetype_ontology.should have_language 'en'
  end

  it 'does not have language es' do
    @archetype_ontology.should_not have_language 'es'
  end

  it 'has terminology SNOMED-CT(2003)' do
    @archetype_ontology.should have_terminology 'SNOMED-CT(2003)'
  end

  it 'does not have MHLW code' do
    @archetype_ontology.should_not have_terminology 'MHLW'
  end

  it 'term binding code_string is 163020007' do
    @archetype_ontology.term_binding(:terminology => 'SNOMED-CT(2003)',
                                     :code => 'at0000').code_string.
      should == '163020007'
  end
end
                            
