require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataStructures::ItemStructure::Representation
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification

describe Element do
  before(:each) do
    value = DvText.new(:value => 'test')
    @element = Element.new(:archetype_node_id => 'at0001',
                           :name => DvText.new(:value => 'element'),
                           :value => value)
  end

  def openehr_null_flavour(code)
    terminology_id = TerminologyID.new(:value => 'openehr')
    defining_code = CodePhrase.new(:terminology_id => terminology_id, :code_string => code)
    DvCodedText.new(:value => 'null flavour', :defining_code => defining_code)
  end

  it 'should be an instance of Element' do
    expect(@element).to be_an_instance_of Element
  end

  it 'value should be assigned as test' do
    expect(@element.value.value).to eq('test')
  end

  it 'nullflavor should be assigned' do
    @element.null_flavor = openehr_null_flavour('271')
    expect(@element.null_flavor.defining_code.code_string).to eq('271')
  end

  it 'should accept a nil null_flavor' do
    expect {
      @element.null_flavor = nil
    }.not_to raise_error
  end

  it 'should raise ArgumentError for a code outside the openEHR null flavours set' do
    expect {
      @element.null_flavor = openehr_null_flavour('999')
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError for a null flavour from a non-openehr terminology' do
    terminology_id = TerminologyID.new(:value => 'local')
    defining_code = CodePhrase.new(:terminology_id => terminology_id, :code_string => '271')
    other = DvCodedText.new(:value => 'null flavour', :defining_code => defining_code)
    expect {
      @element.null_flavor = other
    }.to raise_error ArgumentError
  end

  describe 'RM 1.1.0 null_reason' do
    it 'defaults to nil' do
      expect(@element.null_reason).to be_nil
    end

    it 'accepts a null_reason when null_flavor is already set' do
      @element.null_flavor = openehr_null_flavour('271')
      reason = DvText.new(:value => 'not recorded during triage')
      @element.null_reason = reason
      expect(@element.null_reason).to equal(reason)
    end

    it 'accepts a null_reason at construction time alongside null_flavor' do
      reason = DvText.new(:value => 'not recorded during triage')
      element = Element.new(:archetype_node_id => 'at0001',
                            :name => DvText.new(:value => 'element'),
                            :null_flavor => openehr_null_flavour('271'),
                            :null_reason => reason)
      expect(element.null_reason).to equal(reason)
    end

    it 'raises ArgumentError for a null_reason without a null_flavor' do
      expect {
        @element.null_reason = DvText.new(:value => 'not recorded during triage')
      }.to raise_error ArgumentError
    end
  end
end
