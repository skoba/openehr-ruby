require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Generic

describe PartyIdentified do
  before(:each) do
    external_ref = double(PartyRef, :namespace => 'unknown')
    identifiers = double(Array, :size => 5, :empty? => false)
    @party_identified = PartyIdentified.new(:name => 'NERV',
                                            :external_ref => external_ref,
                                            :identifiers => identifiers)
  end

  it 'should be an instance of PartyIdentified' do
    expect(@party_identified).to be_an_instance_of PartyIdentified
  end

  it 'should assign name properly' do
    expect(@party_identified.name).to eq('NERV')
  end

  it 'should assign external_ref properly' do
    expect(@party_identified.external_ref.namespace).to eq('unknown')
  end

  it 'should assign identifiers properly' do
    expect(@party_identified.identifiers.size).to be_equal 5
  end

  it 'should raise ArgumentError with all nil' do
    expect {
      PartyIdentified.new
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil name when ex_r and id nil' do
    @party_identified.identifiers = nil
    @party_identified.external_ref = nil
    expect {
      @party_identified.name = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil external_ref when name and id nil' do
    @party_identified.name = nil
    @party_identified.identifiers = nil
    expect {
      @party_identified.external_ref = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil identifiers when name and ex_r nil' do
    @party_identified.name = nil
    @party_identified.external_ref = nil
    expect {
      @party_identified.identifiers = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty identifiers' do
    expect {
      @party_identified.identifiers = Array.new
    }.to raise_error ArgumentError
  end

  describe 'deprecated singular #identifier alias (backward compatibility)' do
    it 'accepts :identifier as a construction keyword' do
      external_ref = double(PartyRef, :namespace => 'unknown')
      identifiers = double(Array, :size => 3, :empty? => false)
      party_identified = PartyIdentified.new(:name => 'NERV',
                                             :external_ref => external_ref,
                                             :identifier => identifiers)
      expect(party_identified.identifiers.size).to be_equal 3
    end

    it '#identifier reads the same value as #identifiers' do
      expect(@party_identified.identifier).to eq(@party_identified.identifiers)
    end

    it '#identifier= writes the same attribute as #identifiers=' do
      new_identifiers = double(Array, :size => 1, :empty? => false)
      @party_identified.identifier = new_identifiers
      expect(@party_identified.identifiers).to eq(new_identifiers)
    end
  end
end
