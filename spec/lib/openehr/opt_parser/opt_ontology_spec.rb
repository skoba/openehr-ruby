require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'OPTParser#parse ontology' do
  let(:opt) { OpenEHR::Parser::OPTParser.new(File.dirname(__FILE__) + '/minimum_template.opt').parse }

  it "uses the root archetype's real term_definitions instead of a fabricated at0000 placeholder" do
    root_terms = opt.ontology.term_definitions['ja']
    expect(root_terms.map(&:code)).to include('at0000', 'at0001', 'at0002')
  end

  it "matches the root archetype's own captured component_terminologies entry" do
    root_archetype_id = opt.definition.archetype_id.value
    expect(opt.ontology.term_definitions).to eq(opt.component_terminologies[root_archetype_id].term_definitions)
  end
end
