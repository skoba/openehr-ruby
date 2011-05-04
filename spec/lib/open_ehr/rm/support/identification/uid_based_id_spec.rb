require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe UIDBasedID do
  before(:each) do
    @uid_based_id = UIDBasedID.new(:value => 'rrip::0.0.3')
  end

  it 'should be an instance of UIDBasedID' do
    @uid_based_id.should be_an_instance_of UIDBasedID
  end

  it 'value should be rrip::0.0.3' do
    @uid_based_id.value.should == 'rrip::0.0.3'
  end

  it 'root should be rrip' do
    @uid_based_id.root.value.should == 'rrip'
  end

  it 'extention should be 0.0.3' do
    @uid_based_id.extension.should == '0.0.3'
  end

  it 'should have extension' do
    @uid_based_id.has_extension?.should be_true
  end

  describe 'when extension is empty' do
    before(:each) do
      @uid_based_id = UIDBasedID.new(:value => '10001')
    end

    it 'value should be 10001' do
      @uid_based_id.value.should == '10001'
    end

    it 'has_extension? should not be true' do
      @uid_based_id.has_extension?.should_not be_true
    end

    it 's extention should be empty' do
      @uid_based_id.extension.should == ''
    end

    it 's root should be 10001' do
      @uid_based_id.root.value.should == '10001'
    end
  end
end
