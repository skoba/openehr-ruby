require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::AM::Archetype

describe ValidityKind do
  before(:each) do
    @validity_kind = ValidityKind.new(:value => 1002)
  end

  it 'should be an instance of ValidityKind' do
    @validity_kind.should be_an_instance_of ValidityKind
  end

  it 'mandatory should be equal 1001' do
    ValidityKind::MANDATORY.should be_equal 1001
  end

  it 'optional should be equal 1002' do
    ValidityKind::OPTIONAL.should be_equal 1002
  end

  it 'disallowed should be equal 1003' do
    ValidityKind::DISALLOWED.should be_equal 1003
  end

  it 'should not raise ArgumentError with valid value' do
    expect {
      [1001, 1002, 1003].each {|value| @validity_kind.value = value}
    }.not_to raise_error
  end

  it 'should raise ArgumentError with invalid value such as 1000' do
    expect {
      @validity_kind.value = 1000
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with invalid value such as 1004' do
    expect {
      @validity_kind.value = 1004
    }.to raise_error ArgumentError
  end
end
