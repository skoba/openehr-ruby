require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe PartyRef do
  before(:each) do
    object_id = double(ObjectID, :value => 'test')
    @party_ref = PartyRef.new(:id => object_id,
                              :type => 'PERSON',
                              :namespace => 'test')
  end

  it 'should be an instance of PartyRef' do
    expect(@party_ref).to be_an_instance_of PartyRef
  end

  %w[PERSON ORGANISATION GROUP AGENT ROLE PARTY ACTOR].each do |type|
    it "should not raise ArgumentError with #{type} type" do
      expect {
        @party_ref.type = type
      }.not_to raise_error
    end
  end

  it 'should raise ArgumentError with UNKNOWN type' do
   expect {
      @party_ref.type = 'UNKNOWN'
    }.to raise_error ArgumentError
  end
end
