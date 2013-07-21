require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::RM::DataTypes::Encapsulated

describe Attestation do
  before(:each) do
    committer = double(PartyProxy, :namespace => 'UNKNOWN')
    change_type = double(DvCodedText, :value =>'creation')
    time = double(DvDateTime, :value => '2009-10-03T16:24:19.0Z')
    reason = DvText.new(:value => 'signed')
    items = double(Set, :empty? => false, :size => 3)
    attested_view = double(DvMultimedia, :size => 300)
    @attestation = Attestation.new(:committer => committer,
                                   :change_type => change_type,
                                   :time_committed => time,
                                   :system_id => 'test',
                                   :reason => reason,
                                   :proof => 'DEADBEEFBABE',
                                   :is_pending => true,
                                   :attested_view => attested_view,
                                   :items => items)
  end

  it 'should be an instance of Attestation' do
    @attestation.should be_an_instance_of Attestation
  end

  it 'reason should be signed' do
    @attestation.reason.value.should == 'signed'
  end

  it 'proof should DEADBEEFBABE' do
    @attestation.proof.should == 'DEADBEEFBABE'
  end

  it 'attested view size should be 300' do
    @attestation.attested_view.size.should == 300
  end

  it 'is_pending? should true' do
    @attestation.is_pending?.should be_true
  end

  it 'items size should be 30' do
    @attestation.items.size.should == 3
  end

  it 'should raise ArgumentError when items are empty' do
    expect {
      @attestation.items = Set.new
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentErro when items are nil' do
    expect {
      @attestation.items = nil
    }.not_to raise_error
  end
end
