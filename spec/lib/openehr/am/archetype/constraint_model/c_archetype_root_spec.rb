require 'spec_helper'

describe OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot do
  let(:occurrences) { OpenEHR::AssumedLibraryTypes::Interval.new(lower: 1, upper: 1, lower_included: true, upper_included: true)}
  let(:c_archetype_slot) { OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot.new(rm_type_name: 'COMPOSITION', occurrences: occurrences, node_id: 'at0001', slot_node_id: 'at0038')}

  it 'should be an instance of CArchetypeRoot' do
    expect(c_archetype_slot).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot
  end

  it 'node_id should be at0001' do
    expect(c_archetype_slot.node_id).to eq 'at0001'
  end

  it 'slot node id should be at0038' do
    expect(c_archetype_slot.slot_node_id).to eq 'at0038'
  end

  it 'slot node id should not be empty' do
    expect{c_archetype_slot.slot_node_id = ''}.to raise_error(ArgumentError)
  end

  it 'slot node id allows nil' do
    expect{c_archetype_slot.slot_node_id = nil}.not_to raise_error
  end
end
