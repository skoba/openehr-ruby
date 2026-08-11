require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::AssumedLibraryTypes
include OpenEHR::RM::DataTypes::Quantity
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataStructures::ItemStructure::Representation

# Hand-built constraint tree, mirroring a minimal archetype:
#
#   CLUSTER[at0000] matches {
#     items cardinality matches {2..2; unordered} matches {
#       ELEMENT[at0001] matches {  -- systolic
#         value matches { DV_COUNT matches { magnitude matches {0..300} } }
#       }
#       ELEMENT[at0002] matches {  -- diastolic
#         value matches { DV_COUNT matches { magnitude matches {0..200} } }
#       }
#     }
#   }
describe 'CComplexObject#valid_value? (integration)' do
  let(:mandatory) { Interval.new(:lower => 1, :upper => 1, :lower_included => true, :upper_included => true) }

  def element_constraint(node_id, magnitude_range)
    magnitude_attribute =
      CSingleAttribute.new(:rm_attribute_name => 'magnitude',
                           :existence => mandatory,
                           :children => [CPrimitiveObject.new(:rm_type_name => 'Integer',
                                                                :occurrences => mandatory,
                                                                :item => CInteger.new(:range => magnitude_range))])
    dv_count = CComplexObject.new(:rm_type_name => 'DV_COUNT', :occurrences => mandatory,
                                  :attributes => [magnitude_attribute])
    value_attribute = CSingleAttribute.new(:rm_attribute_name => 'value',
                                           :existence => mandatory,
                                           :children => [dv_count])
    CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => node_id, :occurrences => mandatory,
                       :attributes => [value_attribute])
  end

  let(:systolic) { element_constraint('at0001', Interval.new(:lower => 0, :upper => 300)) }
  let(:diastolic) { element_constraint('at0002', Interval.new(:lower => 0, :upper => 200)) }

  let(:items_attribute) do
    CMultipleAttribute.new(:rm_attribute_name => 'items',
                           :existence => mandatory,
                           :cardinality => Cardinality.new(:interval => Interval.new(:lower => 2, :upper => 2,
                                                                                       :lower_included => true,
                                                                                       :upper_included => true)),
                           :children => [systolic, diastolic])
  end

  let(:cluster_constraint) do
    CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory,
                       :attributes => [items_attribute])
  end

  def element(node_id, magnitude)
    Element.new(:archetype_node_id => node_id, :name => DvText.new(:value => node_id),
               :value => DvCount.new(:magnitude => magnitude))
  end

  def cluster(*items)
    Cluster.new(:archetype_node_id => 'at0000', :name => DvText.new(:value => 'vitals'), :items => items)
  end

  it 'is true when both elements are present, in range and correctly discriminated by node_id' do
    value = cluster(element('at0001', 120), element('at0002', 80))
    expect(cluster_constraint.valid_value?(value)).to be true
  end

  it 'is false when one element is missing (cardinality and per-child occurrences both violated)' do
    value = cluster(element('at0001', 120))
    expect(cluster_constraint.valid_value?(value)).to be false
  end

  it 'is false when a node_id is duplicated instead of the other being present' do
    value = cluster(element('at0001', 120), element('at0001', 130))
    expect(cluster_constraint.valid_value?(value)).to be false
  end

  it 'is false when a value is outside its own element constraint' do
    value = cluster(element('at0001', 120), element('at0002', 999))
    expect(cluster_constraint.valid_value?(value)).to be false
  end

  it 'is false when an element with an unrecognised node_id is present' do
    value = cluster(element('at0001', 120), element('at0099', 80))
    expect(cluster_constraint.valid_value?(value)).to be false
  end
end
