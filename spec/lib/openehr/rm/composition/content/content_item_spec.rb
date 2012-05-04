require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Composition::Content
include OpenEHR::RM::DataTypes::Text

describe ContentItem do
  before(:each) do
    @content_item = ContentItem.new(:name => DvText.new(:value => 'item'),
                                    :archetype_node_id => 'at0001')
  end

  it 'should be an instance of ContentItem' do
    @content_item.should be_an_instance_of ContentItem
  end
end
