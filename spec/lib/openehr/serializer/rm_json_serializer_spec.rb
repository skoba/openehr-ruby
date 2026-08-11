require File.dirname(__FILE__) + '/../../../spec_helper'
require 'json'
include OpenEHR::Serializer
include OpenEHR::RM::DataTypes::Basic
include OpenEHR::RM::DataTypes::Quantity
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataStructures::ItemStructure::Representation
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe RMJSONSerializer do
  it 'serializes a simple DataValue with a _type discriminator' do
    result = JSON.parse(RMJSONSerializer.new(DvBoolean.new(:value => true)).serialize)
    expect(result).to eq({'_type' => 'DV_BOOLEAN', 'value' => true})
  end

  it 'serializes nested RM instances recursively' do
    count = DvCount.new(:magnitude => 5)
    element = Element.new(:archetype_node_id => 'at0001', :name => DvText.new(:value => 'count'), :value => count)

    result = JSON.parse(RMJSONSerializer.new(element).serialize)
    expect(result['_type']).to eq('ELEMENT')
    expect(result['archetype_node_id']).to eq('at0001')
    expect(result['name']).to eq({'_type' => 'DV_TEXT', 'value' => 'count'})
    expect(result['value']).to include('_type' => 'DV_COUNT', 'magnitude' => 5)
  end

  it 'serializes arrays of RM instances' do
    element = Element.new(:archetype_node_id => 'at0001', :name => DvText.new(:value => 'x'), :value => DvBoolean.new(:value => true))
    cluster = Cluster.new(:archetype_node_id => 'at0000', :name => DvText.new(:value => 'c'), :items => [element])

    result = JSON.parse(RMJSONSerializer.new(cluster).serialize)
    expect(result['items']).to be_an(Array)
    expect(result['items'].size).to eq(1)
    expect(result['items'].first['_type']).to eq('ELEMENT')
  end

  it 'excludes the parent back-reference, avoiding infinite recursion' do
    element = Element.new(:archetype_node_id => 'at0001', :name => DvText.new(:value => 'x'), :value => DvBoolean.new(:value => true))
    cluster = Cluster.new(:archetype_node_id => 'at0000', :name => DvText.new(:value => 'c'), :items => [element])
    expect(element.parent).to eq(cluster)

    result = nil
    expect { result = JSON.parse(RMJSONSerializer.new(cluster).serialize) }.not_to raise_error
    expect(result['items'].first).not_to have_key('parent')
  end

  it 'is a generic object-graph walker, also usable for AOM constraint trees' do
    occurrences = Interval.new(:lower => 1, :upper => 1, :lower_included => true, :upper_included => true)
    node = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => occurrences)

    result = JSON.parse(RMJSONSerializer.new(node).serialize)
    expect(result['_type']).to eq('C_COMPLEX_OBJECT')
    expect(result['rm_type_name']).to eq('CLUSTER')
    expect(result['node_id']).to eq('at0000')
    expect(result).not_to have_key('parent')
  end

  it 'exposes JSONSerializer as the same walker, for the AOM-facing name' do
    expect(JSONSerializer).to equal(RMJSONSerializer)
  end
end
