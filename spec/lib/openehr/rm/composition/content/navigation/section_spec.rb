require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::Composition::Content::Navigation
include OpenEHR::RM::DataTypes::Text

describe Section do
  before(:each) do
    items = stub(Array, :empty? => false, :size => 10)
    @section = Section.new(:archetype_node_id => 'at0001',
                           :name => DvText.new(:value => 'section'),
                           :items => items)
  end

  it 'should be an instance of Section' do
    @section.should be_an_instance_of Section
  end

  it 'items should be assigned properly' do
    @section.items.size.should be_equal 10
  end

  it 'empty items should raise ArgumentError' do
    lambda {
      @section.items = [ ]
    }.should raise_error ArgumentError
  end

  it 'nil items should not raise ArgumentError' do
    lambda {
      @section.items = nil
    }.should_not raise_error ArgumentError
  end
end
