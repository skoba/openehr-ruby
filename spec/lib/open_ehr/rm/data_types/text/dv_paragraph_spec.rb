require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Text

describe DvParagraph do
  before(:each) do
    items_dummy = Array[1,2]
    @dv_paragraph = DvParagraph.new(:items => items_dummy)
  end

  it 's items should be_size 2' do
    @dv_paragraph.items.size.should be_equal 2
  end
end
