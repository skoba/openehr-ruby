require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe VersionTreeID do
  before(:each) do
    @version_tree_id = VersionTreeID.new(:value => '1.2.3')
  end

  it 'should be an instance of VersionTreeID' do
    @version_tree_id.should be_an_instance_of VersionTreeID
  end

  it 'value should be 1.2.3' do
    @version_tree_id.value.should == '1.2.3'
  end

  it 'trunk_version should 1' do
    @version_tree_id.trunk_version.should == '1'
  end

  it 'branch_number should 2' do
    @version_tree_id.branch_number.should == '2'
  end

  it 'branch_version should 3' do
    @version_tree_id.branch_version.should == '3'
  end

  it 'is_first? should be true' do
    @version_tree_id.is_first?.should be_true
  end

  it 'is_branch? should be true' do
    @version_tree_id.is_branch?.should be_true
  end

  it 'should raise ArgumentError with nil trunk version' do
    lambda {
      @version_tree_id.trunk_version = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with 0 trunk version' do
    lambda {
      @version_tree_id.trunk_version = 0
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with 0 branch number' do
    lambda {
      @version_tree_id.branch_number = 0
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with 0 branch version' do
    lambda {
      @version_tree_id.branch_version = 0
    }.should raise_error ArgumentError
  end

  describe 'partial version tree id' do
    describe 'version 4.5' do
      before(:each) do
        @version_tree_id = VersionTreeID.new(:value => '4.5')
      end

      it 'value should be 4.5' do
        @version_tree_id.value.should == '4.5'
      end

      it 'should be nil branch version' do
        @version_tree_id.branch_version.should be_nil
      end

      it 'is_first? should not be true' do
        @version_tree_id.is_first?.should_not be_true
      end
    end

    describe 'version 6' do
      before(:each) do
        @version_tree_id = VersionTreeID.new(:value => '6')
      end

      it 'value should be 6' do
        @version_tree_id.value.should == '6'
      end

      it 'should be nil branch number' do
        @version_tree_id.branch_number.should be_nil
      end

      it 'is_branch should not be true' do
        @version_tree_id.is_branch?.should_not be_true
      end

      it 'should raise ArgumentError if assinged branch version' do
        lambda {
          @version_tree_id.branch_version = '7'
        }.should raise_error ArgumentError
      end
    end
  end
end
