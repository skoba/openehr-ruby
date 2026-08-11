require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Text

describe DvParagraph do
  before(:each) do
    items_dummy = Array[1,2]
    @dv_paragraph = DvParagraph.new(:items => items_dummy)
  end

  it 's items should be_size 2' do
    expect(@dv_paragraph.items.size).to be_equal 2
  end

  # RM 1.0.4 deprecated DV_PARAGRAPH in favour of DV_TEXT/DV_CODED_TEXT
  # with markdown or newlines; it remains legal for legacy data, so this
  # only warns (removal is a 2.0/3.0 concern, not a validation error).
  it 'warns that DV_PARAGRAPH is deprecated' do
    expect {
      DvParagraph.new(:items => [1, 2])
    }.to output(/\[DEPRECATED\] DvParagraph/).to_stderr
  end
end
