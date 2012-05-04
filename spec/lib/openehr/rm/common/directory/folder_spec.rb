require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Directory
include OpenEHR::RM::DataTypes::Text

describe Folder do
  before(:each) do
    items = stub(Array, :size => 3)
    folders = stub(Array, :size => 5, :empty? => false)
    @folder = Folder.new(:archetype_node_id => 'at0001',
                         :name => DvText.new(:value => 'test'),
                         :items => items,
                         :folders => folders)
  end

  it 'should an instance of Folder' do
    @folder.should be_an_instance_of Folder
  end

  it 'items size should be 3' do
    @folder.items.size.should == 3
  end

  it 'folders size should be 5' do
    @folder.folders.size.should == 5
  end
end
