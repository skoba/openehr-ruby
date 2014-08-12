require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe Timezone do
  before(:each) do
    @timezone = Timezone.new('+0930')
  end

  it 'hour is 9' do
    expect(@timezone.hour).to be 9
  end

  it 'minute is 30' do
    expect(@timezone.minute).to be 30
  end

  it 'minutes is alias of minute' do
    expect(@timezone.minutes).to be @timezone.minute
  end

  it 'hours is alias of hour' do
    expect(@timezone.hours).to be @timezone.hour
  end

  it '+0930 as string' do
    expect(@timezone.to_s).to eq('+0930')
  end

  describe 'Z timezone' do
    before(:each) do
      @timezone = Timezone.new('Z')
    end

    it 'hour is 0' do
      expect(@timezone.hour).to be 0
    end

    it 'minute is 0' do
      expect(@timezone.minute).to be 0
    end
  end
end
