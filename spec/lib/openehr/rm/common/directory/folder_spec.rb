require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Directory
include OpenEHR::RM::DataTypes::Text

describe Folder do
  before(:each) do
    items = double(Array, :size => 3)
    folders = double(Array, :size => 5, :empty? => false)
    @folder = Folder.new(:archetype_node_id => 'at0001',
                         :name => DvText.new(:value => 'test'),
                         :items => items,
                         :folders => folders)
  end

  it 'should an instance of Folder' do
    expect(@folder).to be_an_instance_of Folder
  end

  it 'items size should be 3' do
    expect(@folder.items.size).to eq(3)
  end

  it 'folders size should be 5' do
    expect(@folder.folders.size).to eq(5)
  end
end
