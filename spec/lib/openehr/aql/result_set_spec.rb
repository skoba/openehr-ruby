require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/fixtures/blood_pressure_builder'
require 'json'

# ResultSet#to_json follows the openEHR REST Query API's result-set
# shape closely enough to be useful (columns/rows), without chasing
# every optional metadata field the full spec allows - see the class
# header comment for the exact scope.
describe OpenEHR::AQL::ResultSet do
  let(:composition) { OpenEHR::AQL::Fixtures::BloodPressureBuilder.blood_pressure_composition(systolic: 150, diastolic: 95) }

  describe '#each / Enumerable' do
    it 'iterates rows' do
      result_set = described_class.new(columns: %w[a b], rows: [[1, 2], [3, 4]])
      expect(result_set.to_a).to eq([[1, 2], [3, 4]])
      expect(result_set.map(&:sum)).to eq([3, 7])
    end
  end

  describe '#to_json' do
    it 'includes column names and passes primitive row values through as-is' do
      result_set = described_class.new(columns: %w[systolic label], rows: [[150, 'high']])
      parsed = JSON.parse(result_set.to_json)

      expect(parsed['columns']).to eq([{ 'name' => 'systolic' }, { 'name' => 'label' }])
      expect(parsed['rows']).to eq([[150, 'high']])
    end

    it 'passes nil row values through as JSON null' do
      result_set = described_class.new(columns: ['x'], rows: [[nil]])
      expect(JSON.parse(result_set.to_json)['rows']).to eq([[nil]])
    end

    it 'serializes an RM object row value via RMJSONSerializer' do
      result_set = described_class.new(columns: ['c'], rows: [[composition]])
      row = JSON.parse(result_set.to_json)['rows'].first

      expect(row.first['_type']).to eq('COMPOSITION')
      expect(row.first['archetype_node_id']).to eq('openEHR-EHR-COMPOSITION.encounter.v1')
    end

    it 'produces valid, re-parseable JSON end to end' do
      result_set = described_class.new(columns: %w[c n], rows: [[composition, 42]])
      expect { JSON.parse(result_set.to_json) }.not_to raise_error
    end
  end
end
