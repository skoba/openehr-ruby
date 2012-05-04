require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::DataStructures
include OpenEHR::RM::DataTypes::Text

describe DataStructure do
  before(:each) do
    name = DvText.new(:value => 'test')
    @data_structure = DataStructure.new(:archetype_node_id => 'at0001',
                                        :name => name)
  end

  it 'should be an instance of DataStructure' do
    @data_structure.should be_an_instance_of DataStructure
  end

  it 'should raise NotImplementedError' do
    lambda {
      @data_structure.as_hierarchy
    }.should raise_error NotImplementedError
  end
end
