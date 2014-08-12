require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe VersionTreeID do
  before(:each) do
    @version_tree_id = VersionTreeID.new(:value => '1.2.3')
  end

  it 'should be an instance of VersionTreeID' do
    expect(@version_tree_id).to be_an_instance_of VersionTreeID
  end

  it 'value should be 1.2.3' do
    expect(@version_tree_id.value).to eq('1.2.3')
  end

  it 'trunk_version should 1' do
    expect(@version_tree_id.trunk_version).to eq('1')
  end

  it 'branch_number should 2' do
    expect(@version_tree_id.branch_number).to eq('2')
  end

  it 'branch_version should 3' do
    expect(@version_tree_id.branch_version).to eq('3')
  end

  it 'is_first? should be true' do
    expect(@version_tree_id.is_first?).to be_truthy
  end

  it 'is_branch? should be true' do
    expect(@version_tree_id.is_branch?).to be_truthy
  end

  it 'should raise ArgumentError with nil trunk version' do
    expect {
      @version_tree_id.trunk_version = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with 0 trunk version' do
    expect {
      @version_tree_id.trunk_version = 0
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with 0 branch number' do
    expect {
      @version_tree_id.branch_number = 0
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with 0 branch version' do
    expect {
      @version_tree_id.branch_version = 0
    }.to raise_error ArgumentError
  end

  describe 'partial version tree id' do
    describe 'version 4.5' do
      before(:each) do
        @version_tree_id = VersionTreeID.new(:value => '4.5')
      end

      it 'value should be 4.5' do
        expect(@version_tree_id.value).to eq('4.5')
      end

      it 'should be nil branch version' do
        expect(@version_tree_id.branch_version).to be_nil
      end

      it 'is_first? should not be true' do
        expect(@version_tree_id.is_first?).not_to be_truthy
      end
    end

    describe 'version 6' do
      before(:each) do
        @version_tree_id = VersionTreeID.new(:value => '6')
      end

      it 'value should be 6' do
        expect(@version_tree_id.value).to eq('6')
      end

      it 'should be nil branch number' do
        expect(@version_tree_id.branch_number).to be_nil
      end

      it 'is_branch should not be true' do
        expect(@version_tree_id.is_branch?).not_to be_truthy
      end

      it 'should raise ArgumentError if assinged branch version' do
        expect {
          @version_tree_id.branch_version = '7'
        }.to raise_error ArgumentError
      end
    end
  end
end
