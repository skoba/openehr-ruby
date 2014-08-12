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
end



