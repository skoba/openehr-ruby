require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe ISO8601Timezone do
  before(:each) do
    @iso8601timezone = ISO8601Timezone.new('+0900')
  end

  it 'should be an instance of ISO8601Timezone' do
    @iso8601timezone.should be_an_instance_of ISO8601Timezone
  end

  it 'sign should be +1' do
    @iso8601timezone.sign.should == +1
  end

  it 'hour should be 9' do
    @iso8601timezone.hour.should == 9
  end

  it 'minute should be 0' do
    @iso8601timezone.minute.should == 0
  end

  it 'should be +0900 as string' do
    @iso8601timezone.as_string.should == '+0900'
  end

  it 'should not be gmt' do
    @iso8601timezone.is_gmt?.should_not be_true
  end

  it 'should raise ArgumentError with invalid format' do
    lambda {
      ISO8601Timezone.new('ABCDE')
    }.should raise_error ArgumentError
  end

  it 'should allow - sign' do
    @iso8601timezone = ISO8601Timezone.new('-5000')
    @iso8601timezone.as_string.should == '-5000'
  end

  describe 'GMT' do
    before(:each) do
      @iso8601timezone = ISO8601Timezone.new('Z')
    end

    it 'should racognize UTC as Z' do
      @iso8601timezone.as_string.should == '+0000'
    end

    it 'should be gmt(almost)' do
      @iso8601timezone.is_gmt?.should be_true
    end
  end
end
