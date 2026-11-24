# frozen_string_literal: true

require File.dirname(__FILE__) + '/../../../spec_helper'

# Issue #58, resolution shape (b) enhancement: CArchetypeRoot gains its own
# term_definitions / term_bindings, populated per root by OPTParser.
# Before, the only home for a root's terms was
# component_terminologies[archetype_id], which is keyed by archetype id and
# so keeps just the last occurrence when a template embeds one archetype
# more than once. Written red-first against master d5e3a90.
#
# Fixtures: jp_referral_repeated_roots_reduced.opt (reduced; two
# EVALUATION.clinical_synopsis.v1 roots side by side, renamed per root) and
# bmi_term_bindings_reduced.opt (reduced; one root with term_bindings).
describe 'OpenEHR::Parser::OPTParser per-root terminology (#58)' do
  def parse(file)
    OpenEHR::Parser::OPTParser.new(File.join(File.dirname(__FILE__), file)).parse
  end

  def roots_of(c_object, found = [])
    found << c_object if c_object.is_a?(OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot)
    attributes = c_object.respond_to?(:attributes) ? c_object.attributes : nil
    (attributes || []).each { |attribute| (attribute.children || []).each { |child| roots_of(child, found) } }
    found
  end

  let(:synopsis_id) { 'openEHR-EHR-EVALUATION.clinical_synopsis.v1' }
  let(:template) { parse('jp_referral_repeated_roots_reduced.opt') }
  let(:synopsis_roots) { roots_of(template.definition).select { |root| root.archetype_id.value == synopsis_id } }

  def text_of(root, code)
    root.term_definitions['ja'][code].items['text']
  end

  it 'gives each of two roots embedding the same archetype its own at0000 text' do
    expect(synopsis_roots.map { |root| text_of(root, 'at0000') }).to eq(%w[症状経過及び検査結果 治療経過])
  end

  it 'keeps the two roots apart even though they sit at one and the same path' do
    expect(synopsis_roots.map(&:path).uniq.size).to eq(1)
    expect(synopsis_roots.map { |root| text_of(root, 'at0000') }.uniq.size).to eq(2)
  end

  it 'keeps a per-root renamed ELEMENT term (at0002) per root as well' do
    expect(synopsis_roots.map { |root| text_of(root, 'at0002') }).to eq(%w[症状経過及び検査結果 治療経過])
  end

  it 'shapes term_definitions as { language => { code => ArchetypeTerm } } with every code of that root' do
    definitions = synopsis_roots.first.term_definitions
    expect(definitions.keys).to eq(['ja'])
    expect(definitions['ja'].keys).to eq(%w[at0000 at0001 at0002 at0003 at0004])
    expect(definitions['ja'].values).to all(be_an(OpenEHR::AM::Archetype::Terminology::ArchetypeTerm))
  end

  it 'gives every root its own term_definitions, the top-level definition included' do
    roots = roots_of(template.definition)
    expect(roots.size).to eq(4)
    expect(roots.map { |root| text_of(root, 'at0000') })
      .to eq(%w[jp_referral 紹介状の詳細情報 症状経過及び検査結果 治療経過])
  end

  it 'leaves term_bindings nil on a root whose archetype has none' do
    expect(synopsis_roots.first).to respond_to(:term_bindings)
    expect(synopsis_roots.map(&:term_bindings)).to eq([nil, nil])
  end

  it 'puts term_bindings on the root as { terminology => { code => [CodePhrase] } }' do
    bmi = roots_of(parse('bmi_term_bindings_reduced.opt').definition)
          .find { |root| root.archetype_id.value == 'openEHR-EHR-OBSERVATION.body_mass_index.v2' }
    expect(bmi.term_bindings.keys).to contain_exactly('SNOMED-CT', 'LOINC')
    expect(bmi.term_bindings['LOINC']['at0004'].map(&:code_string)).to eq(['[LOINC::39156-5]'])
  end

  it 'answers nil for both on a CArchetypeRoot built without them' do
    root = OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot.new(
      rm_type_name: 'CLUSTER', path: '/', occurrences: OpenEHR::AssumedLibraryTypes::Interval.new(lower: 0, upper: 1),
      archetype_id: OpenEHR::RM::Support::Identification::ArchetypeID.new(value: synopsis_id)
    )
    expect([root.term_definitions, root.term_bindings]).to eq([nil, nil])
  end

  it 'leaves component_terminologies[archetype_id] as it was: last root wins, { language => [ArchetypeTerm] } (regression pin)' do
    # regression pin: the keyed-by-archetype aggregation is kept unchanged
    # for compatibility, including its (different) Array shape.
    terms = template.component_terminologies[synopsis_id].term_definitions['ja']
    expect(terms).to be_an(Array)
    expect(terms.find { |term| term.code == 'at0000' }.items['text']).to eq('治療経過')
  end
end
