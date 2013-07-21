require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Composition
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::Common::Generic

describe Composition do
  before(:each) do
    name = DvText.new(:value => 'composition test')
    language = double(CodePhrase, :code_string => 'ja')
    category = double(DvCodedText, :value => 'event')
    territory = double(CodePhrase, :code_string => 'jpn')
    external_ref = double(PartyRef, :type =>  'ROLE')
    composer = double(PartyProxy, :external_ref => external_ref)
    content = double(Array, :size => 3)
    context = double(EventContext, :location => 'lab1')
    @composition = Composition.new(:archetype_node_id => 'at0001',
                                   :name => name,
                                   :language => language,
                                   :category => category,
                                   :territory => territory,
                                   :composer => composer,
                                   :content => content,
                                   :context => context)
  end

  it 'should be an instance of Composition' do
    @composition.should be_an_instance_of Composition
  end

  it 'language should be assigned properly' do
    @composition.language.code_string.should == 'ja'
  end

  it 'should validate language with Termonology service'

  it 'should raise ArgumentError with nil language' do
    lambda {
      @composition.language = nil
    }.should raise_error ArgumentError
  end

  it 'category should be assigned properly' do
    @composition.category.value.should == 'event'
  end

  it 'should validate category with Terminology service'

  it 'should raise ArgumentError with nil category' do
    lambda {
      @composition.category = nil
    }.should raise_error ArgumentError
  end

  it 'territory should be assined properly' do
    @composition.territory.code_string.should == 'jpn'
  end

  it 'should raise ArgumentError with nil territory' do
    lambda {
      @composition.territory = nil
    }.should raise_error ArgumentError
  end

  it 'composer should be assigned properly' do
    @composition.composer.external_ref.type.should == 'ROLE'
  end

  it 'should raise ArgumentError with nil comosser' do
    lambda {
      @composition.composer = nil
    }.should raise_error ArgumentError
  end

  it 'is_persistent? should be false when category is not persistent' do
    @composition.is_persistent?.should be_false
  end

  it 'is_persistent? should be true when category is persistent' do
    category = double(DvCodedText, :value => 'persistent')
    @composition.category = category
    @composition.is_persistent?.should be_true
  end

  it 'content should be assigned properly' do
    @composition.content.size.should == 3
  end

  it 'context should be assigned properly' do
    @composition.context.location.should == 'lab1'
  end
end
