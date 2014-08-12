require 'set'

describe OpenEHR::AM::Archetype::Archetype do
  before(:each) do
    original_language = double(OpenEHR::RM::DataTypes::Text::CodePhrase, :code_string => 'ja')
    archetype_id = OpenEHR::RM::Support::Identification::ArchetypeID.new(:value => 'openEHR-EHR-SECTION.physical_examination-prenatal.v2')
    definition = double(OpenEHR::AM::Archetype::ConstraintModel::CComplexObject, :rm_type_name => 'SECTION')
    items = {'text' => 'Physical examination'}
    term1 = OpenEHR::AM::Archetype::Ontology::ArchetypeTerm.new(:code => 'at0000', :items => items)
    ontology = OpenEHR::AM::Archetype::Ontology::ArchetypeOntology.new(:specialisation_depth => 1, :term_definitions => {'ja' => {'at0000' =>term1}})
    uid = OpenEHR::RM::Support::Identification::HierObjectID.new(:value => 'ABCD::1')
    parent_archetype_id = OpenEHR::RM::Support::Identification::ArchetypeID.new(:value => 'openEHR-EHR-SECTION.physical_examination.v1')
    invariants = double(Set, :size => 2)
    @archetype = OpenEHR::AM::Archetype::Archetype.new(:original_language => original_language,
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
    expect(@archetype).to be_an_instance_of OpenEHR::AM::Archetype::Archetype
  end

  it 'adl_version should be assigned properly' do
    expect(@archetype.adl_version).to eq('1.4')
  end
  
  it 'archetype_id should be assigned prorperly' do
    expect(@archetype.archetype_id.value).to eq('openEHR-EHR-SECTION.physical_examination-prenatal.v2')
  end

  it 'should raise ArgumentError when archetype_id is nil' do
    expect {
      @archetype.archetype_id = nil
    }.to raise_error ArgumentError
  end

  it 'uid should be assigned properly' do
    expect(@archetype.uid.value).to eq('ABCD::1')
  end

  it 'concept should be assigned properly' do
    expect(@archetype.concept).to eq('at0000')
  end

  it 'should raise ArgumentError when concept is nil' do
    expect {
      @archetype.concept = nil
    }.to raise_error ArgumentError
  end

  it 'parent_archetype_id should be assigned properly' do
    expect(@archetype.parent_archetype_id.value).to eq('openEHR-EHR-SECTION.physical_examination.v1')
  end

  it 'definition should be assigned properly' do
    expect(@archetype.definition.rm_type_name).to eq('SECTION')
  end

  it 'should raise ArgumentError when definition is nil' do
    expect {
      @archetype.definition = nil
    }.to raise_error ArgumentError
  end
  
  it 'ontology should be assigned properly' do
    expect(@archetype.ontology.specialisation_depth).to be_equal 1
  end

  it 'should raise ArgumentError when ontology is nil' do
    expect {
      @archetype.ontology = nil
    }.to raise_error ArgumentError
  end

  it 'invariants should be assigned properly' do
    expect(@archetype.invariants.size).to be_equal 2
  end

  it 'version should be extracted form id' do
    expect(@archetype.version).to eq('v2')
  end

  it 'short concept name should be extracted from archetype id' do
    expect(@archetype.short_concept_name).to eq('physical_examination')
  end

  it 'concept name should be extracted from ontology' do
    expect(@archetype.concept_name('ja')).to eq('Physical examination')
  end
end
