require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../adl_parser/parser_spec_helper'
require 'rexml/document'
include OpenEHR::Serializer
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::AM::OpenEHRProfile::DataTypes::Text
include OpenEHR::AssumedLibraryTypes

describe 'XMLSerializer#definition (recursive emitter)' do
  let(:mandatory) { Interval.new(:lower => 1, :upper => 1, :lower_included => true, :upper_included => true) }
  let(:optional) { Interval.new(:lower => 0, :upper => 1, :lower_included => true, :upper_included => true) }

  def serializer_for(definition)
    archetype = double('archetype', :definition => definition)
    XMLSerializer.new(archetype)
  end

  def doc_for(definition)
    REXML::Document.new("<root xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">#{serializer_for(definition).definition}</root>")
  end

  it 'emits upper as occurrences.upper, not occurrences.lower (regression for a copy/paste bug)' do
    node = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000',
                              :occurrences => Interval.new(:lower => 0, :upper => 5, :lower_included => true, :upper_included => true))
    doc = doc_for(node)
    expect(REXML::XPath.first(doc, '//definition/occurrence/lower').text).to eq('0')
    expect(REXML::XPath.first(doc, '//definition/occurrence/upper').text).to eq('5')
  end

  it 'still renders an any_allowed complex object with no attributes element' do
    node = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory)
    doc = doc_for(node)
    expect(REXML::XPath.first(doc, '//definition/rm_type_name').text).to eq('CLUSTER')
    expect(REXML::XPath.first(doc, '//definition/attributes')).to be_nil
  end

  it 'recurses into nested attributes and children instead of stopping at the root' do
    child = CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'at0001', :occurrences => mandatory)
    items_attribute = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => optional,
                                             :cardinality => Cardinality.new(:interval => Interval.new(:lower => 0, :upper => nil, :lower_included => true),
                                                                              :is_ordered => false, :is_unique => false),
                                             :children => [child])
    node = CComplexObject.new(:rm_type_name => 'ITEM_TREE', :node_id => 'at0000', :occurrences => mandatory,
                              :attributes => [items_attribute])
    doc = doc_for(node)

    expect(REXML::XPath.first(doc, '//definition/attributes/rm_attribute_name').text).to eq('items')
    expect(REXML::XPath.first(doc, '//definition/attributes/cardinality/interval/lower').text).to eq('0')
    expect(REXML::XPath.first(doc, "//definition/attributes/children[@xsi:type='C_COMPLEX_OBJECT']/rm_type_name").text).to eq('ELEMENT')
    expect(REXML::XPath.first(doc, "//definition/attributes/children/node_id").text).to eq('at0001')
  end

  it 'emits a C_PRIMITIVE_OBJECT child with its range' do
    attribute = CSingleAttribute.new(:rm_attribute_name => 'magnitude', :existence => mandatory,
                                     :children => [CPrimitiveObject.new(:rm_type_name => 'Integer', :occurrences => mandatory,
                                                                          :item => CInteger.new(:range => Interval.new(:lower => 0, :upper => 100)))])
    node = CComplexObject.new(:rm_type_name => 'DV_COUNT', :node_id => 'at0000', :occurrences => mandatory,
                              :attributes => [attribute])
    doc = doc_for(node)
    child = REXML::XPath.first(doc, "//definition/attributes/children[@xsi:type='C_PRIMITIVE_OBJECT']")
    expect(child).not_to be_nil
    expect(REXML::XPath.first(child, 'range/lower').text).to eq('0')
    expect(REXML::XPath.first(child, 'range/upper').text).to eq('100')
  end

  it 'emits a CONSTRAINT_REF child with its reference' do
    attribute = CSingleAttribute.new(:rm_attribute_name => 'defining_code', :existence => mandatory,
                                     :children => [ConstraintRef.new(:rm_type_name => 'CodePhrase', :occurrences => mandatory,
                                                                       :reference => 'ac0001')])
    node = CComplexObject.new(:rm_type_name => 'DV_CODED_TEXT', :node_id => 'at0000', :occurrences => mandatory,
                              :attributes => [attribute])
    doc = doc_for(node)
    expect(REXML::XPath.first(doc, "//definition/attributes/children[@xsi:type='CONSTRAINT_REF']/reference").text).to eq('ac0001')
  end

  describe 'against real archetypes' do
    it 'produces well-formed XML for openEHR-EHR-CLUSTER.anatomical_location.v1.adl, including its slots' do
      archetype = adl14_archetype('openEHR-EHR-CLUSTER.anatomical_location.v1.adl')
      xml = XMLSerializer.new(archetype).definition
      doc = nil
      expect { doc = REXML::Document.new("<root xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">#{xml}</root>") }.not_to raise_error
      expect(REXML::XPath.match(doc, "//children[@xsi:type='ARCHETYPE_SLOT']").size).to eq(2)
    end
  end
end
