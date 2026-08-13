require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../adl_parser/parser_spec_helper'
require 'tempfile'
require 'timeout'
include OpenEHR::Serializer
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::AM::OpenEHRProfile::DataTypes::Text
include OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
include OpenEHR::AssumedLibraryTypes
include OpenEHR::RM::Support::Identification

describe 'ADLSerializer#definition (recursive cADL emitter)' do
  let(:mandatory) { Interval.new(:lower => 1, :upper => 1, :lower_included => true, :upper_included => true) }
  let(:optional) { Interval.new(:lower => 0, :upper => 1, :lower_included => true, :upper_included => true) }

  def serializer_for(definition)
    archetype = double('archetype', :definition => definition)
    ADLSerializer.new(archetype)
  end

  it 'still renders an any_allowed complex object as {*} (no infinite loop)' do
    node = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory)
    definition = nil
    expect { definition = serializer_for(node).definition }.not_to raise_error
    expect(definition).to eq("definition#{OpenEHR::Serializer::NL}    CLUSTER[at0000] matches {*}#{OpenEHR::Serializer::NL}")
  end

  it 'terminates instead of looping forever when attributes are present' do
    value_attribute =
      CSingleAttribute.new(:rm_attribute_name => 'value', :existence => mandatory,
                           :children => [CPrimitiveObject.new(:rm_type_name => 'Boolean', :occurrences => mandatory,
                                                                :item => CBoolean.new(:true_valid => true, :false_valid => false))])
    node = CComplexObject.new(:rm_type_name => 'DV_BOOLEAN', :node_id => 'at0000', :occurrences => mandatory,
                              :attributes => [value_attribute])

    definition = nil
    expect { Timeout.timeout(2) { definition = serializer_for(node).definition } }.not_to raise_error
    expect(definition).to include('value matches {True}')
  end

  describe 'primitive rendering' do
    def primitive_definition(item)
      attribute = CSingleAttribute.new(:rm_attribute_name => 'value', :existence => mandatory,
                                       :children => [CPrimitiveObject.new(:rm_type_name => 'Any', :occurrences => mandatory,
                                                                            :item => item)])
      node = CComplexObject.new(:rm_type_name => 'DV_COUNT', :node_id => 'at0000', :occurrences => mandatory,
                                :attributes => [attribute])
      serializer_for(node).definition
    end

    it 'renders CBoolean as True/False' do
      expect(primitive_definition(CBoolean.new(:true_valid => true, :false_valid => true)))
        .to include('value matches {True, False}')
    end

    it 'renders CInteger range with pipes' do
      expect(primitive_definition(CInteger.new(:range => Interval.new(:lower => 0, :upper => 100))))
        .to include('value matches {|0..100|}')
    end

    it 'renders CInteger list' do
      expect(primitive_definition(CInteger.new(:list => [1, 2, 3])))
        .to include('value matches {1, 2, 3}')
    end

    it 'renders an unconstrained primitive as *' do
      expect(primitive_definition(CInteger.new)).to include('value matches {*}')
    end

    it 'renders CString pattern' do
      expect(primitive_definition(CString.new(:pattern => 'cardio.*')))
        .to include('value matches {cardio.*}')
    end

    it 'renders CString list' do
      expect(primitive_definition(CString.new(:list => ['a', 'b'])))
        .to include('value matches {"a", "b"}')
    end

    it 'renders an assumed_value suffix' do
      expect(primitive_definition(CInteger.new(:range => Interval.new(:lower => 0, :upper => 100), :assumed_value => 10)))
        .to include('value matches {|0..100|; 10}')
    end
  end

  it 'renders a CMultipleAttribute with cardinality and existence' do
    child = CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'at0001', :occurrences => mandatory)
    items_attribute = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => optional,
                                             :cardinality => Cardinality.new(:interval => Interval.new(:lower => 0, :upper => nil, :lower_included => true),
                                                                              :is_ordered => false, :is_unique => false),
                                             :children => [child])
    node = CComplexObject.new(:rm_type_name => 'ITEM_TREE', :node_id => 'at0000', :occurrences => mandatory,
                              :attributes => [items_attribute])

    definition = serializer_for(node).definition
    expect(definition).to include('existence matches {0..1}')
    expect(definition).to include('cardinality matches {0..*; unordered}')
    expect(definition).to include('ELEMENT[at0001] matches {*}')
  end

  it 'renders a CCodePhrase constraint' do
    term_id = TerminologyID.new(:value => 'local')
    attribute = CSingleAttribute.new(:rm_attribute_name => 'defining_code', :existence => mandatory,
                                     :children => [CCodePhrase.new(:rm_type_name => 'CodePhrase', :occurrences => mandatory,
                                                                     :terminology_id => term_id, :code_list => ['at0003', 'at0004'])])
    node = CComplexObject.new(:rm_type_name => 'DV_CODED_TEXT', :node_id => 'at0000', :occurrences => mandatory,
                              :attributes => [attribute])
    expect(serializer_for(node).definition).to include('defining_code matches {[local::at0003, at0004]}')
  end

  it 'renders a ConstraintRef as a bare [ac-code]' do
    attribute = CSingleAttribute.new(:rm_attribute_name => 'defining_code', :existence => mandatory,
                                     :children => [ConstraintRef.new(:rm_type_name => 'CodePhrase', :occurrences => mandatory,
                                                                       :reference => 'ac0001')])
    node = CComplexObject.new(:rm_type_name => 'DV_CODED_TEXT', :node_id => 'at0000', :occurrences => mandatory,
                              :attributes => [attribute])
    expect(serializer_for(node).definition).to include('defining_code matches {[ac0001]}')
  end

  it 'renders an ArchetypeInternalRef as use_node' do
    ref = ArchetypeInternalRef.new(:rm_type_name => 'ELEMENT', :occurrences => mandatory, :target_path => '/items[at0001]')
    items_attribute = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory,
                                             :cardinality => Cardinality.new(:interval => Interval.new(:lower => 0, :upper => nil, :lower_included => true)),
                                             :children => [ref])
    node = CComplexObject.new(:rm_type_name => 'ITEM_TREE', :node_id => 'at0000', :occurrences => mandatory,
                              :attributes => [items_attribute])
    expect(serializer_for(node).definition).to include('use_node ELEMENT /items[at0001]')
  end

  it 'renders an ArchetypeSlot as allow_archetype with include assertions' do
    assertion = double('assertion', :string_expression => "archetype_id/value matches {/openEHR-EHR-CLUSTER\\.foo\\.v1/}")
    slot = ArchetypeSlot.new(:rm_type_name => 'CLUSTER', :node_id => 'at0053', :occurrences => optional,
                             :includes => [assertion])
    items_attribute = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => optional,
                                             :cardinality => Cardinality.new(:interval => Interval.new(:lower => 0, :upper => nil, :lower_included => true)),
                                             :children => [slot])
    node = CComplexObject.new(:rm_type_name => 'ITEM_TREE', :node_id => 'at0000', :occurrences => mandatory,
                              :attributes => [items_attribute])
    definition = serializer_for(node).definition
    expect(definition).to include('allow_archetype CLUSTER[at0053]')
    expect(definition).to include('include')
    expect(definition).to include("archetype_id/value matches {/openEHR-EHR-CLUSTER\\.foo\\.v1/}")
  end

  describe 'round trip against real archetypes' do
    def round_trip(file)
      archetype = adl14_archetype(file)
      serializer = ADLSerializer.new(archetype)
      text = serializer.header + OpenEHR::Serializer::NL + serializer.description +
             OpenEHR::Serializer::NL + serializer.definition + OpenEHR::Serializer::NL + serializer.ontology

      tempfile = Tempfile.new(['roundtrip', '.adl'])
      tempfile.write(text)
      tempfile.close
      begin
        OpenEHR::Parser::ADLParser.new(tempfile.path).parse
      ensure
        tempfile.unlink
      end
    end

    it 're-parses openEHR-EHR-CLUSTER.anatomical_location.v1.adl into an equivalent archetype' do
      original = adl14_archetype('openEHR-EHR-CLUSTER.anatomical_location.v1.adl')
      reparsed = round_trip('openEHR-EHR-CLUSTER.anatomical_location.v1.adl')

      expect(reparsed.archetype_id.value).to eq(original.archetype_id.value)
      expect(reparsed.physical_paths.sort).to eq(original.physical_paths.sort)
      expect(reparsed.node_ids_valid?).to be true
    end

    def find_cdv_quantity(node)
      return node if node.is_a?(CDvQuantity)
      return nil unless node.respond_to?(:attributes) && node.attributes

      node.attributes.each do |attribute|
        (attribute.children || []).each do |child|
          found = find_cdv_quantity(child)
          return found if found
        end
      end
      nil
    end

    it 're-parses a fully specified C_DV_QUANTITY into an equivalent archetype' do
      original = adl14_archetype('adl-test-entry.c_dv_quantity_full.test.adl')
      reparsed = round_trip('adl-test-entry.c_dv_quantity_full.test.adl')

      expect(reparsed.physical_paths.sort).to eq(original.physical_paths.sort)
      expect(reparsed.node_ids_valid?).to be true

      original_node = find_cdv_quantity(original.definition)
      reparsed_node = find_cdv_quantity(reparsed.definition)
      expect(reparsed_node.property.code_string).to eq(original_node.property.code_string)
      expect(reparsed_node.list.size).to eq(original_node.list.size)
      expect(reparsed_node.assumed_value.magnitude).to eq(original_node.assumed_value.magnitude)
    end

    it 're-parses an any_allowed C_DV_QUANTITY into an equivalent archetype' do
      reparsed = round_trip('adl-test-entry.c_dv_quantity_empty.test.adl')

      reparsed_node = find_cdv_quantity(reparsed.definition)
      expect(reparsed_node.any_allowed?).to be true
    end
  end
end
