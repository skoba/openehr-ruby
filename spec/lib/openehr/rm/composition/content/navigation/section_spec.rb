require 'spec_helper'

describe OpenEHR::RM::Composition::Content::Navigation::Section do
  before(:each) do
    items = double(Array, :empty? => false, :size => 10)
    @section = OpenEHR::RM::Composition::Content::Navigation::Section.new(
                           :archetype_node_id => 'at0001',
                           :name => OpenEHR::RM::DataTypes::Text::DvText.new(:value => 'section'),
                           :items => items)
  end

  it 'should be an instance of Section' do
    @section.should be_an_instance_of OpenEHR::RM::Composition::Content::Navigation::Section
  end

  it 'items should be assigned properly' do
    @section.items.size.should be_equal 10
  end

  it 'empty items should raise ArgumentError' do
    expect {
      @section.items = [ ]
    }.to raise_error ArgumentError
  end

  it 'nil items should not raise ArgumentError' do
    expect {
      @section.items = nil
    }.not_to raise_error
  end
end
