require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe UIDBasedID do
  before(:each) do
    @uid_based_id = UIDBasedID.new(:value => 'rrip::0.0.3')
  end

  it 'should be an instance of UIDBasedID' do
    expect(@uid_based_id).to be_an_instance_of UIDBasedID
  end

  it 'value should be rrip::0.0.3' do
    expect(@uid_based_id.value).to eq('rrip::0.0.3')
  end

  it 'root should be rrip' do
    expect(@uid_based_id.root.value).to eq('rrip')
  end

  it 'extention should be 0.0.3' do
    expect(@uid_based_id.extension).to eq('0.0.3')
  end

  it 'should have extension' do
    expect(@uid_based_id.has_extension?).to be_truthy
  end

  describe 'when extension is empty' do
    before(:each) do
      @uid_based_id = UIDBasedID.new(:value => '10001')
    end

    it 'value should be 10001' do
      expect(@uid_based_id.value).to eq('10001')
    end

    it 'has_extension? should not be true' do
      expect(@uid_based_id.has_extension?).not_to be_truthy
    end

    it 's extention should be empty' do
      expect(@uid_based_id.extension).to eq('')
    end

    it 's root should be 10001' do
      expect(@uid_based_id.root.value).to eq('10001')
    end
  end
end
