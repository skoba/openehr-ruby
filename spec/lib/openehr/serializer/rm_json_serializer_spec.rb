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
  it 'serializes a genuine mutual back-reference without recursing forever' do
    first = Object.new
    second = Object.new
    first.instance_variable_set(:@other, second)
    second.instance_variable_set(:@other, first)

    result = nil
    expect { result = JSON.parse(RMJSONSerializer.new(first).serialize) }.not_to raise_error
    # regression pin: true cycles resolve to nil at the cyclic link.
    expect(result.dig('other', 'other')).to be_nil
  end

  # Resolution shape (a), bug: the aliased archetype_id reproduced null before the fix.
  it 'serializes both identifiers aliased by an operational template' do
    template_id = OpenEHR::RM::Support::Identification::TemplateID.new(value: 'example.template.v1')
    template = OpenEHR::AM::Template::OperationalTemplate.new(
      template_id: template_id,
      original_language: Object.new,
      description: Object.new,
      definition: Object.new,
      ontology: Object.new
    )

    result = JSON.parse(RMJSONSerializer.new(template).serialize)
    expect(result['archetype_id']).not_to be_nil
    expect(result['archetype_id']).to eq(result['template_id'])
  end

  it 'round-trips the health summary composition through canonical JSON' do
    json = File.read(File.expand_path('../../../fixtures/health_summary_composition.json', __dir__))
    composition = OpenEHR::RM::CompositionFactory.create_from_json(json)
    serialized = RMJSONSerializer.new(composition).serialize

    expect { OpenEHR::RM::CompositionFactory.create_from_json(serialized) }.not_to raise_error
  end

  # This is the gem's existing real-artifact health summary fixture with the
  # originally absent canonical ObjectVersionID uid added to exercise the
  # UID-family round-trip crash discovered while investigating issue #32.
  it 'round-trips the health summary composition carrying a uid through canonical JSON' do
    json = File.read(File.expand_path('../../../fixtures/health_summary_composition_with_uid.json', __dir__))
    composition = OpenEHR::RM::CompositionFactory.create_from_json(json)
    serialized = RMJSONSerializer.new(composition).serialize

    expect { OpenEHR::RM::CompositionFactory.create_from_json(serialized) }.not_to raise_error
  end

  # Watch every object reachable from the fixture, including derived caches
  # excluded by the serializer, so a future cache with no read-side Factory is
  # detected without requiring another fixture change.
  it 'has a Factory or an explicit compatibility exclusion for every typed object in the graph' do
    json = File.read(File.expand_path('../../../fixtures/health_summary_composition_with_uid.json', __dir__))
    composition = OpenEHR::RM::CompositionFactory.create_from_json(json)
    seen = Set.new.compare_by_identity
    visit = lambda do |value|
      case value
      when nil, true, false, Numeric, String
        next
      when Array
        value.each { |element| visit.call(element) }
      when Hash
        value.each_value { |element| visit.call(element) }
      else
        next if seen.include?(value)

        seen << value
        type = OpenEHR::RM.type_name_of(value)
        factory_name = "#{type.downcase.camelize}Factory"
        expect(
          OpenEHR::RM.const_defined?(factory_name) ||
            OpenEHR::RM::Factory::KNOWN_DERIVED_CACHE_TYPES.include?(type)
        ).to be(true), "expected #{type} to have #{factory_name} or be an explicitly excluded derived type"

        (value.instance_variables - [:@parent]).each do |ivar|
          visit.call(value.instance_variable_get(ivar))
        end
      end
    end

    visit.call(composition)
  end

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
