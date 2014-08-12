require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Archetyped

describe Pathable do
  before(:each) do
    @pathable = Pathable.new
  end

  it 'should be an instance of Pathable' do
    expect(@pathable).to be_an_instance_of Pathable
  end

  it 'item_at_path should raise NotImplementedError' do
    expect {
      @pathable.item_at_path('/')
    }.to raise_error NotImplementedError
  end

  it 'items_at_path should raise NotImplementedError' do
    expect {
      @pathable.items_at_path('/')
    }.to raise_error NotImplementedError
  end

  it 'path_exists? should raise NotImplementedError' do
    expect {
      @pathable.path_exists?('/')
    }.to raise_error NotImplementedError
  end

  it 'path_of_item should raise NotImplementedError' do
    expect {
      @pathable.path_of_item('/')
    }.to raise_error NotImplementedError
  end

  it 'path_unique? should raise NotImplementedError' do
    expect {
      @pathable.path_unique?('/')
    }.to raise_error NotImplementedError
  end
end
