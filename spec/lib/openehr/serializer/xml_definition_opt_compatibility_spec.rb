require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../adl_parser/parser_spec_helper'
require 'nokogiri'
include OpenEHR::Serializer
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::AM::Archetype::Assertion
include OpenEHR::AM::OpenEHRProfile::DataTypes::Text
include OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataTypes::Text
include OpenEHR::AssumedLibraryTypes

# XMLSerializer#definition and OPTParser (lib/openehr/parser/opt_parser.rb)
# both need to agree on the <definition> constraint tree shape - OPTParser
# reads real Ocean Template Designer .opt fixtures (spec/lib/openehr/opt_parser/),
# so its private node-construction methods (c_complex_object, attributes,
# children, ...) are the ground truth this spec verifies XMLSerializer's
# output against, node by node, without needing a full XMLArchetypeParser.
describe 'XMLSerializer#definition / OPTParser compatibility' do
  def parse_back(definition_xml)
    wrapped = "<root xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">#{definition_xml}</root>"
    doc = Nokogiri::XML::Document.parse(wrapped)
    doc.remove_namespaces!
    OpenEHR::Parser::OPTParser.allocate.send(:c_complex_object, doc.at('definition'), Node.new)
  end

  let(:mandatory) { Interval.new(:lower => 1, :upper => 1, :lower_included => true, :upper_included => true) }

  it 're-parses a CMultipleAttribute/CSingleAttribute mix via their xsi:type on <attributes>' do
    single = CSingleAttribute.new(:rm_attribute_name => 'value', :existence => mandatory,
                                  :children => [CComplexObject.new(:rm_type_name => 'DV_TEXT', :node_id => 'at0001', :occurrences => mandatory)])
    multiple = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory,
                                      :cardinality => Cardinality.new(:interval => Interval.new(:lower => 0, :upper => nil, :lower_included => true),
                                                                        :is_ordered => false, :is_unique => false),
                                      :children => [CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'at0002', :occurrences => mandatory)])
    node = CComplexObject.new(:rm_type_name => 'ITEM_TREE', :node_id => 'at0000', :occurrences => mandatory, :attributes => [single, multiple])

    reparsed = parse_back(XMLSerializer.new(double('archetype', :definition => node)).definition)

    expect(reparsed.attributes.map(&:class)).to eq([CSingleAttribute, CMultipleAttribute])
    expect(reparsed.attributes[0].children.first.node_id).to eq('at0001')
    expect(reparsed.attributes[1].children.first.node_id).to eq('at0002')
  end

  it 're-parses a C_CODE_PHRASE child with its nested terminology_id and code_list' do
    attribute = CSingleAttribute.new(:rm_attribute_name => 'defining_code', :existence => mandatory,
                                     :children => [CCodePhrase.new(:rm_type_name => 'CODE_PHRASE', :occurrences => mandatory,
                                                                     :terminology_id => TerminologyID.new(:value => 'openehr'),
                                                                     :code_list => %w[433 434])])
    node = CComplexObject.new(:rm_type_name => 'DV_CODED_TEXT', :node_id => 'at0000', :occurrences => mandatory, :attributes => [attribute])

    reparsed = parse_back(XMLSerializer.new(double('archetype', :definition => node)).definition)
    code_phrase = reparsed.attributes.first.children.first

    expect(code_phrase.terminology_id.value).to eq('openehr')
    expect(code_phrase.code_list).to eq(%w[433 434])
  end

  it 're-parses a C_DV_ORDINAL child with its symbol/defining_code nesting' do
    symbol = DvCodedText.new(:value => '[local::at0.1]', :defining_code =>
      CodePhrase.new(:terminology_id => TerminologyID.new(:value => 'local'), :code_string => 'at0.1'))
    ordinal = CDvOrdinal.new(:rm_type_name => 'DvOrdinal', :occurrences => mandatory,
                             :list => [OpenEHR::RM::DataTypes::Quantity::DvOrdinal.new(:value => 1, :symbol => symbol)])
    attribute = CSingleAttribute.new(:rm_attribute_name => 'value', :existence => mandatory, :children => [ordinal])
    node = CComplexObject.new(:rm_type_name => 'DV_ORDINAL', :node_id => 'at0000', :occurrences => mandatory, :attributes => [attribute])

    reparsed = parse_back(XMLSerializer.new(double('archetype', :definition => node)).definition)
    reparsed_ordinal = reparsed.attributes.first.children.first

    expect(reparsed_ordinal.list.first.value).to eq(1)
    expect(reparsed_ordinal.list.first.symbol.defining_code.terminology_id.value).to eq('local')
    expect(reparsed_ordinal.list.first.symbol.defining_code.code_string).to eq('at0.1')
  end

  it 're-parses a C_DV_QUANTITY child with its property and ranged list items' do
    quantity = CDvQuantity.new(:rm_type_name => 'DvQuantity', :occurrences => mandatory,
                               :property => CodePhrase.new(:terminology_id => TerminologyID.new(:value => 'openehr'), :code_string => '128'),
                               :list => [CQuantityItem.new(:units => 'yr', :magnitude => Interval.new(:lower => 0.0, :upper => 200.0),
                                                            :precision => Interval.new(:lower => 2, :upper => 2))])
    attribute = CSingleAttribute.new(:rm_attribute_name => 'value', :existence => mandatory, :children => [quantity])
    node = CComplexObject.new(:rm_type_name => 'DV_QUANTITY', :node_id => 'at0000', :occurrences => mandatory, :attributes => [attribute])

    reparsed = parse_back(XMLSerializer.new(double('archetype', :definition => node)).definition)
    reparsed_quantity = reparsed.attributes.first.children.first

    expect(reparsed_quantity.property.terminology_id.value).to eq('openehr')
    expect(reparsed_quantity.property.code_string).to eq('128')
    expect(reparsed_quantity.list.first.units).to eq('yr')
    expect(reparsed_quantity.list.first.magnitude.lower).to eq(0.0)
    expect(reparsed_quantity.list.first.magnitude.upper).to eq(200.0)
  end

  it 're-parses an ARCHETYPE_SLOT with a real EXPR_BINARY_OPERATOR assertion tree' do
    left = ExprLeaf.new(:type => 'String', :item => 'archetype_id/value', :reference_type => 'attribute')
    right = ExprLeaf.new(:type => 'C_STRING', :item => CString.new(:pattern => 'openEHR-EHR-CLUSTER\..*\.v1'), :reference_type => 'constraint')
    expr = ExprBinaryOperator.new(:type => 'Boolean', :operator => OperatorKind.new(:value => OperatorKind::OP_MATCHES),
                                  :precedence_overridden => false, :left_operand => left, :right_operand => right)
    slot = ArchetypeSlot.new(:rm_type_name => 'CLUSTER', :node_id => 'at0010', :occurrences => mandatory,
                             :includes => [Assertion.new(:expression => expr)])
    attribute = CSingleAttribute.new(:rm_attribute_name => 'other', :existence => mandatory, :children => [slot])
    node = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory, :attributes => [attribute])

    reparsed = parse_back(XMLSerializer.new(double('archetype', :definition => node)).definition)
    reparsed_slot = reparsed.attributes.first.children.first
    reparsed_expr = reparsed_slot.includes.first.expression

    expect(reparsed_slot.node_id).to eq('at0010')
    expect(reparsed_expr).to be_an_instance_of(ExprBinaryOperator)
    expect(reparsed_expr.operator.value).to eq(OperatorKind::OP_MATCHES)
    expect(reparsed_expr.left_operand.item).to eq('archetype_id/value')
    expect(reparsed_expr.right_operand.item.pattern).to eq('openEHR-EHR-CLUSTER\..*\.v1')
  end

  # ADLParser assigns ExprOperator#operator as a bare OperatorKind::OP_*
  # Integer, while OPTParser's own reader wraps it in an OperatorKind -
  # XMLSerializer must emit either shape correctly.
  it 'emits a bare Integer operator (as ADLParser builds it) the same way as an OperatorKind-wrapped one' do
    left = ExprLeaf.new(:type => 'String', :item => 'archetype_id/value', :reference_type => 'attribute')
    right = ExprLeaf.new(:type => 'C_STRING', :item => CString.new(:pattern => '.*'), :reference_type => 'constraint')
    expr = ExprBinaryOperator.new(:type => 'Boolean', :operator => OperatorKind::OP_MATCHES,
                                  :precedence_overridden => false, :left_operand => left, :right_operand => right)
    slot = ArchetypeSlot.new(:rm_type_name => 'CLUSTER', :node_id => 'at0011', :occurrences => mandatory,
                             :includes => [Assertion.new(:expression => expr)])
    attribute = CSingleAttribute.new(:rm_attribute_name => 'other', :existence => mandatory, :children => [slot])
    node = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory, :attributes => [attribute])

    reparsed = parse_back(XMLSerializer.new(double('archetype', :definition => node)).definition)
    expect(reparsed.attributes.first.children.first.includes.first.expression.operator.value).to eq(OperatorKind::OP_MATCHES)
  end

  describe 'against a real archetype' do
    it 're-parses openEHR-EHR-CLUSTER.anatomical_location.v1.adl with no loss of node_ids' do
      archetype = adl14_archetype('openEHR-EHR-CLUSTER.anatomical_location.v1.adl')
      reparsed = parse_back(XMLSerializer.new(archetype).definition)

      def collect_node_ids(node, seen = [])
        seen << node.node_id if node.respond_to?(:node_id) && node.node_id
        (node.attributes || []).each { |a| collect_node_ids(a, seen) } if node.respond_to?(:attributes)
        (node.children || []).each { |c| collect_node_ids(c, seen) } if node.respond_to?(:children)
        seen
      end

      expect(collect_node_ids(reparsed).sort.uniq).to eq(collect_node_ids(archetype.definition).sort.uniq)
    end
  end
end
