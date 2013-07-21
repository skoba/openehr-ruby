require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::DataTypes::Text
describe PartyRelated do
  before(:each) do
    relationship = double(DvCodedText, :value => 'self')
    @party_related = PartyRelated.new(:name => 'TEST',
                                      :relationship => relationship)
  end

  it 'should be an instance of PartyRelated' do
    @party_related.should be_an_instance_of PartyRelated
  end

  it 'should assign relationship properly' do
    @party_related.relationship.value.should == 'self'
  end

  it 'should raise ArgumentError when nil is assigned to relationship' do
    expect {
      @party_related.relationship = nil
    }.to raise_error ArgumentError
  end
end
