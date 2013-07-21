require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Generic

describe PartyIdentified do
  before(:each) do
    external_ref = double(PartyRef, :namespace => 'unknown')
    identifiers = double(Array, :size => 5, :empty? => false)
    @party_identified = PartyIdentified.new(:name => 'NERV',
                                            :external_ref => external_ref,
                                            :identifier => identifiers)
  end

  it 'should be an instance of PartyIdentified' do
    @party_identified.should be_an_instance_of PartyIdentified
  end

  it 'should assign name properly' do
    @party_identified.name.should == 'NERV'
  end

  it 'should assign external_ref properly' do
    @party_identified.external_ref.namespace.should == 'unknown'
  end

  it 'should assign identifier properly' do
    @party_identified.identifier.size.should be_equal 5
  end

  it 'should raise ArgumentError with all nil' do
    expect {
      PartyIdentified.new
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil name when ex_r and id nil' do
    @party_identified.identifier = nil
    @party_identified.external_ref = nil
    expect {
      @party_identified.name = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil external_ref when name and id nil' do
    @party_identified.name = nil
    @party_identified.identifier = nil
    expect {
      @party_identified.external_ref = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil identifier when name and ex_r nil' do
    @party_identified.name = nil
    @party_identified.external_ref = nil
    expect {
      @party_identified.identifier = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty identifier' do
    expect {
      @party_identified.identifier = Array.new
    }.to raise_error ArgumentError
  end
end
