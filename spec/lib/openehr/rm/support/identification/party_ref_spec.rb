require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe PartyRef do
  before(:each) do
    object_id = stub(ObjectID, :value => 'test')
    @party_ref = PartyRef.new(:id => object_id,
                              :type => 'PERSON',
                              :namespace => 'test')
  end

  it 'should be an instance of PartyRef' do
    @party_ref.should be_an_instance_of PartyRef
  end

  %w[PERSON ORGANISATION GROUP AGENT ROLE PARTY ACTOR].each do |type|
    it "should not raise ArgumentError with #{type} type" do
      lambda {
        @party_ref.type = type
      }.should_not raise_error ArgumentError
    end
  end

  it 'should raise ArgumentError with UNKNOWN type' do
    lambda {
      @party_ref.type = 'UNKNOWN'
    }.should raise_error ArgumentError
  end
end
