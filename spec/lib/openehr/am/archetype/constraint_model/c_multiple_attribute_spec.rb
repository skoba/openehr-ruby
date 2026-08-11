require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CMultipleAttribute do
  before(:each) do
    existence = Interval.new(:upper =>0, :lower => 0) 
    cardinality = double(Cardinality, :ordered? => true)
    @c_multiple_attribute =
      CMultipleAttribute.new(:path => '/event/at001',
                             :rm_attribute_name => 'DV_DATE',
                             :existence => existence,
                             :cardinality => cardinality)
  end

  it 'should be an instance of CMulitipleAttribute' do
    expect(@c_multiple_attribute).to be_an_instance_of CMultipleAttribute
  end

  it 'cardinality should be assigned properly' do
    expect(@c_multiple_attribute.cardinality).to be_ordered
  end

  describe '#node_conforms_to?' do
    let(:parent_attribute) do
      CMultipleAttribute.new(:rm_attribute_name => 'items',
                             :existence => Interval.new(:lower => 0, :upper => 1),
                             :cardinality => Cardinality.new(:interval => Interval.new(:lower => 0, :upper => 5)))
    end

    it 'is true when cardinality is a subset of the parent cardinality' do
      child = CMultipleAttribute.new(:rm_attribute_name => 'items',
                                     :existence => Interval.new(:lower => 0, :upper => 1),
                                     :cardinality => Cardinality.new(:interval => Interval.new(:lower => 1, :upper => 3)))
      expect(child.node_conforms_to?(parent_attribute)).to be true
    end

    it 'is false when cardinality is wider than the parent cardinality' do
      child = CMultipleAttribute.new(:rm_attribute_name => 'items',
                                     :existence => Interval.new(:lower => 0, :upper => 1),
                                     :cardinality => Cardinality.new(:interval => Interval.new(:lower => 0, :upper => 10)))
      expect(child.node_conforms_to?(parent_attribute)).to be false
    end

    it 'still enforces rm_attribute_name conformance inherited from CAttribute' do
      child = CMultipleAttribute.new(:rm_attribute_name => 'other',
                                     :existence => Interval.new(:lower => 0, :upper => 1),
                                     :cardinality => Cardinality.new(:interval => Interval.new(:lower => 0, :upper => 1)))
      expect(child.node_conforms_to?(parent_attribute)).to be false
    end
  end
end
