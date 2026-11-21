require File.dirname(__FILE__) + '/../../../spec_helper'

# Issue #31, resolution shape (b) enhancement: OPTParser read only
# term_definitions and dropped an OPT's term_bindings (external
# terminology bindings). The fixture is a reduced real OPT - see its
# leading comment for provenance. Written red-first against master
# f9509c7.
describe 'OPTParser#parse term_bindings (#31)' do
  let(:opt) { OpenEHR::Parser::OPTParser.new(File.dirname(__FILE__) + '/bmi_term_bindings_reduced.opt').parse }
  let(:bmi) { opt.component_terminologies['openEHR-EHR-OBSERVATION.body_mass_index.v2'] }

  it 'puts term_bindings on component_terminologies[archetype_id] as { terminology => { code => [CodePhrase] } }' do
    expect(bmi.term_bindings.keys).to contain_exactly('SNOMED-CT', 'LOINC')
    code_phrases = bmi.term_bindings['SNOMED-CT']['at0004']
    expect(code_phrases.size).to eq 1
    expect(code_phrases.first).to be_an_instance_of OpenEHR::RM::DataTypes::Text::CodePhrase
    expect(code_phrases.first.terminology_id.value).to eq 'SNOMED-CT'
  end

  it 'keeps both bindings when one at-code is bound to more than one terminology' do
    expect(bmi.term_bindings['SNOMED-CT'].keys).to eq ['at0004']
    expect(bmi.term_bindings['LOINC'].keys).to eq ['at0004']
    expect(bmi.term_bindings['LOINC']['at0004'].first.terminology_id.value).to eq 'LOINC'
  end

  it "keeps code_string exactly as the OPT writes it, without decomposing the bracketed form" do
    expect(bmi.term_bindings['SNOMED-CT']['at0004'].first.code_string).to eq '[SNOMED-CT::60621009]'
    expect(bmi.term_bindings['LOINC']['at0004'].first.code_string).to eq '[LOINC::39156-5]'
  end

  it 'answers ArchetypeOntology#term_binding for a bound code' do
    expect(bmi.term_binding(terminology: 'LOINC', code: 'at0004').map(&:code_string)).to eq ['[LOINC::39156-5]']
  end

  # regression pin: already true on master before the fix - an archetype
  # whose OPT section has no <term_bindings> keeps a nil term_bindings
  # (openehr-rails' populate_term_bindings! nil-guard relies on nil
  # meaning "not populated"). Red is not achievable for this example.
  it 'leaves term_bindings nil for an archetype without any (regression pin)' do
    expect(opt.component_terminologies['openEHR-EHR-COMPOSITION.report-result.v1'].term_bindings).to be_nil
    expect(opt.ontology.term_bindings).to be_nil
  end
end
