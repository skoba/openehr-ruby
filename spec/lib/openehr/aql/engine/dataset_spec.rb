require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/../fixtures/blood_pressure_builder'

# See lib/openehr/aql/engine/dataset.rb's header comment for the full
# contract. This spec locks in the three accepted input shapes (Hash,
# duck-typed object, full RM::EHR::EHR), the is_a?(Pathable) firewall,
# and the "construction never iterates" laziness guarantee.
describe OpenEHR::AQL::Dataset do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:composition) { builder.blood_pressure_composition(systolic: 150, diastolic: 95) }

  describe '.new' do
    it 'does not iterate ehrs: at construction time (stays lazy)' do
      exploding_enum = Enumerator.new { raise 'must not be called yet' }
      expect { described_class.new(ehrs: exploding_enum) }.not_to raise_error
    end

    it 'normalizes a symbol-keyed Hash record' do
      dataset = described_class.new(ehrs: [{ ehr_id: 'ehr-1', compositions: [composition] }])
      records = dataset.each_ehr.to_a

      expect(records.size).to eq(1)
      expect(records.first.ehr_id).to eq('ehr-1')
      expect(records.first.compositions).to eq([composition])
      expect(records.first.ehr).to be_nil
      expect(records.first.ehr_status).to be_nil
    end

    it 'normalizes a string-keyed Hash record' do
      dataset = described_class.new(ehrs: [{ 'ehr_id' => 'ehr-1', 'compositions' => [composition] }])
      expect(dataset.each_ehr.to_a.first.ehr_id).to eq('ehr-1')
    end

    it 'unwraps an ehr_id object that responds to #value (e.g. HierObjectID)' do
      hier_id = OpenEHR::RM::Support::Identification::HierObjectID.new(value: 'ehr-1')
      dataset = described_class.new(ehrs: [{ ehr_id: hier_id, compositions: [composition] }])
      expect(dataset.each_ehr.to_a.first.ehr_id).to eq('ehr-1')
    end

    it 'accepts a duck-typed record object' do
      record_class = Struct.new(:ehr_id, :compositions)
      dataset = described_class.new(ehrs: [record_class.new('ehr-1', [composition])])
      expect(dataset.each_ehr.to_a.first.ehr_id).to eq('ehr-1')
    end

    it 'accepts an ehr_status when the Hash record supplies one' do
      ehr_status = double('EHRStatus')
      dataset = described_class.new(ehrs: [{ ehr_id: 'e1', compositions: [composition], ehr_status: ehr_status }])
      expect(dataset.each_ehr.to_a.first.ehr_status).to equal(ehr_status)
    end

    it 'yields multiple EHR records lazily, one per source element' do
      dataset = described_class.new(ehrs: [
        { ehr_id: 'e1', compositions: [composition] },
        { ehr_id: 'e2', compositions: [composition] }
      ])
      expect(dataset.each_ehr.map(&:ehr_id)).to eq(%w[e1 e2])
    end

    it 'raises DatasetError naming the class and index when a composition is not Pathable' do
      dataset = described_class.new(ehrs: [{ ehr_id: 'e1', compositions: [composition, 'not a composition'] }])
      expect { dataset.each_ehr.to_a }.to raise_error(OpenEHR::AQL::DatasetError, /String.*index 1/)
    end

    it 'unwraps a full OpenEHR::RM::EHR::EHR' do
      ehr_status_content = double('EHRStatus')
      versioned_status = double('VersionedEHRStatus', type: 'VERSIONED_EHR_STATUS',
                                 latest_version: double(data: ehr_status_content))
      versioned_composition = double('VersionedComposition', type: 'VERSIONED_COMPOSITION',
                                      latest_version: double(data: composition))
      ehr_access = double('ObjectRef', type: 'VERSIONED_EHR_ACCESS')
      contribution = double('ObjectRef', type: 'CONTRIBUTION')

      ehr = OpenEHR::RM::EHR::EHR.new(
        system_id: OpenEHR::RM::Support::Identification::HierObjectID.new(value: 'system-1'),
        ehr_id: OpenEHR::RM::Support::Identification::HierObjectID.new(value: 'ehr-1'),
        time_created: builder.date_time('2024-01-01T00:00:00+09:00'),
        contributions: [contribution],
        ehr_access: ehr_access,
        ehr_status: versioned_status,
        compositions: [versioned_composition]
      )

      dataset = described_class.new(ehrs: [ehr])
      record = dataset.each_ehr.to_a.first

      expect(record.ehr_id).to eq('ehr-1')
      expect(record.ehr).to equal(ehr)
      expect(record.ehr_status).to equal(ehr_status_content)
      expect(record.compositions).to eq([composition])
    end
  end

  describe '.of_compositions' do
    it 'wraps an Enumerable of compositions as a single synthetic EHR record' do
      dataset = described_class.of_compositions([composition])
      records = dataset.each_ehr.to_a

      expect(records.size).to eq(1)
      expect(records.first.compositions).to eq([composition])
      expect(records.first.ehr_id).to be_nil
    end

    it 'accepts an explicit ehr_id:' do
      dataset = described_class.of_compositions([composition], ehr_id: 'ehr-1')
      expect(dataset.each_ehr.to_a.first.ehr_id).to eq('ehr-1')
    end
  end

  describe '.wrap' do
    it 'passes an existing Dataset through unchanged' do
      dataset = described_class.of_compositions([composition])
      expect(described_class.wrap(dataset)).to equal(dataset)
    end

    it 'wraps a bare Enumerable of Compositions via .of_compositions' do
      dataset = described_class.wrap([composition])
      expect(dataset.each_ehr.to_a.first.compositions).to eq([composition])
    end

    it 'wraps a bare Enumerable of EHR-shaped records via .new(ehrs:)' do
      dataset = described_class.wrap([{ ehr_id: 'e1', compositions: [composition] }])
      expect(dataset.each_ehr.to_a.first.ehr_id).to eq('e1')
    end

    it 'raises DatasetError for anything else' do
      expect { described_class.wrap('not a dataset') }.to raise_error(OpenEHR::AQL::DatasetError)
    end
  end
end
