require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe UUID do
  before(:each) do
    @uuid = UUID.new(:value => 'F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6')
  end

  it 'should be an instance of UUID' do
    expect(@uuid).to be_an_instance_of UUID
  end

  it 'value should be assigned properly' do
    expect(@uuid.value).to eq('F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6')
  end

  it 'should raise ArgumentError with a malformed UUID' do
    expect {
      UUID.new(:value => 'not-a-uuid')
    }.to raise_error ArgumentError
  end
end
