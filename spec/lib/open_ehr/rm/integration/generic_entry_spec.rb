require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Integration
include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::DataTypes::Text

describe GenericEntry do
  before(:each) do
    data = stub(ItemTree, :archetype_node_id => 'at0003')
    name = DvText.new(:value => 'generic entry')
    @generic_entry = GenericEntry.new(:archetype_node_id => 'at0001',
                                      :name => name,
                                      :data => data)
  end

  it 'should be an instance of GenericEntry' do
    @generic_entry.should be_an_instance_of GenericEntry
  end

  it 'data should be assigned properly' do
    @generic_entry.data.archetype_node_id.should == 'at0003'
  end

  it 'should raise ArgumentError when data are nil' do
    lambda {
      @generic_entry.data = nil
    }.should raise_error ArgumentError
  end
end
                                      

  
