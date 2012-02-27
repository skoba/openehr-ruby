require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe Timezone do
  before(:each) do
    @timezone = Timezone.new('+0930')
  end

  it 'hour is 9' do
    @timezone.hour.should be 9
  end

  it 'minute is 30' do
    @timezone.minute.should be 30
  end

  it 'minutes is alias of minute' do
    @timezone.minutes.should be @timezone.minute
  end

  it 'hours is alias of hour' do
    @timezone.hours.should be @timezone.hour
  end

  it '+0930 as string' do
    @timezone.to_s.should == '+0930'
  end

  describe 'Z timezone' do
    before(:each) do
      @timezone = Timezone.new('Z')
    end

    it 'hour is 0' do
      @timezone.hour.should be 0
    end

    it 'minute is 0' do
      @timezone.minute.should be 0
    end
  end
end
