require 'spec_helper'

describe OpenEHR::AM::Archetype::FlatArchetype do
  let(:original_language) { double(OpenEHR::RM::DataTypes::Text::CodePhrase)}
  let(:archetype_id) { double(OpenEHR::RM::Support::Identification::ArchetypeID)}
  let(:definition) { double(OpenEHR::AM::Archetype::ConstraintModel::CComplexObject) }
  let(:ontology) { double(OpenEHR::AM::Archetype::Ontology::ArchetypeOntology) }
  let(:flat_archetype) { OpenEHR::AM::Archetype::FlatArchetype.new(original_language: original_language, archetype_id: archetype_id, concept: 'test', definition: definition, ontology: ontology) }

  it 'should be an instance of FlatArchetype' do
    expect(flat_archetype).to be_an_instance_of OpenEHR::AM::Archetype::FlatArchetype
  end
end
