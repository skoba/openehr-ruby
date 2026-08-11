require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CAttribute do
  before(:each) do
    existence = Interval.new(:lower => 0, :upper => 1)
    parent = double(CObject, :path => '/event[at0001]')
    occurrences = existence
    children = [CObject.new(:rm_type_name => 'DV_AMOUNT',
                            :occurrences => occurrences)]
    @c_attribute = CAttribute.new(:parent => parent,
                                  :rm_attribute_name => 'data',
                                  :existence => existence,
                                  :children => children)
  end

  it 'should be an instance of CAttribute' do
    expect(@c_attribute).to be_an_instance_of CAttribute
  end

  it 'rm_attribute_name should be assigned properly' do
    expect(@c_attribute.rm_attribute_name).to eq('data')
  end

  it 'should raise ArguemntError rm_attribute_name is empty' do
    expect {
      @c_attribute.rm_attribute_name = ''
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError rm_attribute_name is nil' do
    expect {
      @c_attribute.rm_attribute_name = nil
    }.to raise_error ArgumentError
  end

  it 'existence should be assigned properly' do
    expect(@c_attribute.existence.lower).to be_equal 0
  end

  it 'existence.lower should be more than 0' do
    invalid_existence = Interval.new(:lower => -1, :upper => 1)
    expect {
      @c_attribute.existence = invalid_existence
    }.to raise_error ArgumentError
  end

  it 'existence.upper should be equal or less than 1' do
    invalid_existence = Interval.new(:lower => 0, :upper => 2)
    expect {
      @c_attribute.existence = invalid_existence
    }.to raise_error ArgumentError
  end


  context 'children' do
    it 'children should be assigned properly' do
      expect(@c_attribute.children[0].rm_type_name).to eq('DV_AMOUNT')
    end

    it 'children parent should be set properly' do
      expect(@c_attribute.children[0].parent).to eq(@c_attribute)
    end

    it 'has children' do
      expect(@c_attribute).to have_children
    end
  end
  it 'path should be calculated properly' do
    expect(@c_attribute.path).to eq('/event[at0001]/data')
  end

  context 'path' do
    before(:each) do
      @c_attribute.path = '/event[at0001]/new'
    end

    it 'should be assigned properly' do
      expect(@c_attribute.path).to eq('/event[at0001]/new')
    end
  end

  describe '#node_conforms_to?' do
    let(:parent_attribute) do
      CAttribute.new(:rm_attribute_name => 'data',
                     :existence => Interval.new(:lower => 0, :upper => 1))
    end

    it 'is true when rm_attribute_name matches and existence is a subset' do
      child = CAttribute.new(:rm_attribute_name => 'data',
                             :existence => Interval.new(:lower => 1, :upper => 1))
      expect(child.node_conforms_to?(parent_attribute)).to be true
    end

    it 'is false when rm_attribute_name differs' do
      child = CAttribute.new(:rm_attribute_name => 'state',
                             :existence => Interval.new(:lower => 0, :upper => 1))
      expect(child.node_conforms_to?(parent_attribute)).to be false
    end

    it 'is false when existence is wider than the parent existence' do
      mandatory_parent = CAttribute.new(:rm_attribute_name => 'data',
                                        :existence => Interval.new(:lower => 1, :upper => 1))
      child = CAttribute.new(:rm_attribute_name => 'data',
                             :existence => Interval.new(:lower => 0, :upper => 1))
      expect(child.node_conforms_to?(mandatory_parent)).to be false
    end

    it 'is true when the parent existence is unconstrained' do
      unconstrained_parent = CAttribute.new(:rm_attribute_name => 'data')
      child = CAttribute.new(:rm_attribute_name => 'data',
                             :existence => Interval.new(:lower => 1, :upper => 1))
      expect(child.node_conforms_to?(unconstrained_parent)).to be true
    end

    it 'is false when self is unconstrained but the parent existence is constrained' do
      child = CAttribute.new(:rm_attribute_name => 'data')
      expect(child.node_conforms_to?(parent_attribute)).to be false
    end

    it 'is false when other is nil' do
      expect(parent_attribute.node_conforms_to?(nil)).to be false
    end
  end
end



