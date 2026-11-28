# frozen_string_literal: true

require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/../fixtures/blood_pressure_builder'

# #156, resolution shape (b) enhancement: COMPOSITION's category,
# language, territory and composer (its name, and its external_ref's id)
# are reachable from an AQL path. The added names are reachable only on
# the RM type they belong to (TYPED_TERMINAL_HOPS). Plan:
# docs/design/156-aql-composition-attributes-plan.md.
describe 'AQL: COMPOSITION category, language, territory and composer (#156)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:identification) { OpenEHR::RM::Support::Identification }
  let(:from) { 'FROM EHR e CONTAINS COMPOSITION c' }
  let(:plain) { builder.blood_pressure_composition(systolic: 120, diastolic: 80) }
  let(:referenced) do
    builder.blood_pressure_composition(systolic: 130, diastolic: 85).tap do |composition|
      composition.composer = OpenEHR::RM::Common::Generic::PartyIdentified.new(
        name: 'Dr. Ref',
        external_ref: identification::PartyRef.new(
          namespace: 'local', type: 'PERSON',
          id: identification::GenericID.new(value: 'clinician-0001', scheme: 'local')
        )
      )
    end
  end

  def select(path, compositions, where: nil)
    query = "SELECT #{path} #{from}"
    query += " WHERE #{where}" if where
    OpenEHR::AQL.execute(query, OpenEHR::AQL::Dataset.of_compositions(compositions)).rows.flatten
  end

  {
    'c/category/value' => 'event',
    'c/category/defining_code/code_string' => '433',
    'c/language/code_string' => 'en',
    'c/territory/code_string' => 'JP',
    'c/composer/name' => 'Dr. Test'
  }.each do |path, expected|
    it "SELECT #{path} returns #{expected}" do
      expect(select(path, [plain])).to eq [expected]
    end
  end

  it "SELECT c/composer/external_ref/id/value returns the id, and null when there is no external_ref" do
    expect(select('c/composer/external_ref/id/value', [referenced, plain])).to eq ['clinician-0001', nil]
  end

  it 'WHERE on the category code selects the composition' do
    expect(select('c/composer/name', [plain], where: "c/category/defining_code/code_string = '433'")).to eq ['Dr. Test']
    expect(select('c/composer/name', [plain], where: "c/category/defining_code/code_string = '431'")).to eq []
  end

  it 'WHERE on the composer name selects that composition' do
    expect(select('c/composer/name', [plain, referenced], where: "c/composer/name = 'Dr. Ref'")).to eq ['Dr. Ref']
  end

  # Collision sweep (plan): language and id are readers on other RM types
  # too; the added names stay unreachable there. regression pin: these
  # already raised before #156.
  describe 'the added names on other RM types' do
    it 'does not reach an ENTRY language' do
      query = "SELECT o/language/code_string #{from} CONTAINS OBSERVATION o"
      expect { OpenEHR::AQL.execute(query, OpenEHR::AQL::Dataset.of_compositions([plain])) }
        .to raise_error(OpenEHR::AQL::ExecutionError, /unsupported path attribute "language"/)
    end

    it 'does not reach a DV_IDENTIFIER id' do
      identifier = OpenEHR::RM::DataTypes::Basic::DvIdentifier.new(id: 'MRN-1')
      expect(OpenEHR::AQL::PathEvaluator.terminal_hop_allowed?(identifier, 'id')).to be false
    end
  end
end
