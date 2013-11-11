require 'spec_helper'

describe OpenEHR::AM::Archetype::Ontology::FlatArchetypeOntology do
  let(:term_definition) { double(OpenEHR::AM::Archetype::Ontology::ArchetypeTerm) }
  let(:flat_archetype_ontology) { OpenEHR::AM::Archetype::Ontology::FlatArchetypeOntology.new(term_definitions: [term_definition]) }

  it 'should be an instance of FlatArchetypeOntology' do
    expect(flat_archetype_ontology).to be_an_instance_of OpenEHR::AM::Archetype::Ontology::FlatArchetypeOntology
  end
end
