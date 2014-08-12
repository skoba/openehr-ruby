require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe ISO8601Timezone do
  before(:each) do
    @iso8601timezone = ISO8601Timezone.new('+0900')
  end

  it 'should be an instance of ISO8601Timezone' do
    expect(@iso8601timezone).to be_an_instance_of ISO8601Timezone
  end

  it 'sign should be +1' do
    expect(@iso8601timezone.sign).to eq +1
  end

  it 'hour should be 9' do
    expect(@iso8601timezone.hour).to eq(9)
  end

  it 'minute should be 0' do
    expect(@iso8601timezone.minute).to eq(0)
  end

  it 'should be +0900 as string' do
    expect(@iso8601timezone.as_string).to eq('+0900')
  end

  it 'should not be gmt' do
    expect(@iso8601timezone.is_gmt?).not_to be_truthy
  end

  it 'should raise ArgumentError with invalid format' do
    expect {
      ISO8601Timezone.new('ABCDE')
    }.to raise_error ArgumentError
  end

  it 'should allow - sign' do
    @iso8601timezone = ISO8601Timezone.new('-5000')
    expect(@iso8601timezone.as_string).to eq('-5000')
  end

  describe 'GMT' do
    before(:each) do
      @iso8601timezone = ISO8601Timezone.new('Z')
    end

    it 'should racognize UTC as Z' do
      expect(@iso8601timezone.as_string).to eq('+0000')
    end

    it 'should be gmt(almost)' do
      expect(@iso8601timezone.is_gmt?).to be_truthy
    end
  end
end
