require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/blood_pressure_builder'

describe OpenEHR::AQL::Fixtures::BloodPressureBuilder do
  describe '.blood_pressure_composition' do
    let(:composition) { described_class.blood_pressure_composition(systolic: 150, diastolic: 95) }

    it 'builds a real, valid Composition' do
      expect(composition).to be_an_instance_of(OpenEHR::RM::Composition::Composition)
    end

    it 'is Pathable, navigable down to the systolic/diastolic magnitudes' do
      systolic = composition.item_at_path(
        '/content[openEHR-EHR-OBSERVATION.blood_pressure.v1]/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value'
      )
      diastolic = composition.item_at_path(
        '/content[openEHR-EHR-OBSERVATION.blood_pressure.v1]/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value'
      )
      expect(systolic.magnitude).to eq(150)
      expect(diastolic.magnitude).to eq(95)
    end

    it 'has an archetype_node_id matching the blood_pressure archetype, for CONTAINS predicate matching' do
      observation = composition.item_at_path('/content[openEHR-EHR-OBSERVATION.blood_pressure.v1]')
      expect(observation.archetype_node_id).to eq('openEHR-EHR-OBSERVATION.blood_pressure.v1')
    end

    it 'has a real EVENT_CONTEXT with start_time' do
      expect(composition.context.start_time.value).to start_with('2024-01-01T10:00:00')
    end
  end

  describe '.body_temperature_composition' do
    let(:composition) { described_class.body_temperature_composition }

    it 'builds a real, valid Composition whose content is NOT a blood_pressure observation' do
      observation = composition.content.first
      expect(observation.archetype_node_id).to eq('openEHR-EHR-OBSERVATION.body_temperature.v1')
    end
  end
end
