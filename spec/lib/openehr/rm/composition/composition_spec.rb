require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Composition
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::Common::Generic

describe Composition do
  before(:each) do
    name = DvText.new(:value => 'composition test')
    language = double(CodePhrase, :code_string => 'ja')
    category_code = double(CodePhrase, :code_string => '433')
    category = double(DvCodedText, :value => 'event', :defining_code => category_code)
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
    expect(@composition).to be_an_instance_of Composition
  end

  it 'language should be assigned properly' do
    expect(@composition.language.code_string).to eq('ja')
  end

  it 'should validate language with Terminology service' do
    strict_provider = Class.new do
      def valid_code?(terminology_id, code)
        terminology_id == 'ISO_639-1' && code == 'ja'
      end
    end.new
    OpenEHR::TerminologyService.provider = strict_provider
    expect {
      @composition.language = double(CodePhrase, :code_string => 'not-a-real-language')
    }.to raise_error ArgumentError
    expect {
      @composition.language = double(CodePhrase, :code_string => 'ja')
    }.not_to raise_error
  ensure
    OpenEHR::TerminologyService.provider = nil
  end

  it 'should raise ArgumentError with nil language' do
    expect {
      @composition.language = nil
    }.to raise_error ArgumentError
  end

  it 'category should be assigned properly' do
    expect(@composition.category.value).to eq('event')
  end

  it 'should validate category with Terminology service' do
    strict_provider = Class.new do
      def has_code_for_group?(group_id, code)
        group_id == 'composition category' && code == '433'
      end
    end.new
    OpenEHR::TerminologyService.provider = strict_provider
    invalid_code = double(CodePhrase, :code_string => '999')
    expect {
      @composition.category = double(DvCodedText, :value => 'event', :defining_code => invalid_code)
    }.to raise_error ArgumentError
    expect {
      @composition.category = double(DvCodedText, :value => 'event', :defining_code => double(CodePhrase, :code_string => '433'))
    }.not_to raise_error
  ensure
    OpenEHR::TerminologyService.provider = nil
  end

  it 'should raise ArgumentError with nil category' do
    expect {
      @composition.category = nil
    }.to raise_error ArgumentError
  end

  it 'territory should be assined properly' do
    expect(@composition.territory.code_string).to eq('jpn')
  end

  it 'should raise ArgumentError with nil territory' do
    expect {
      @composition.territory = nil
    }.to raise_error ArgumentError
  end

  it 'composer should be assigned properly' do
    expect(@composition.composer.external_ref.type).to eq('ROLE')
  end

  it 'should raise ArgumentError with nil comosser' do
    expect {
      @composition.composer = nil
    }.to raise_error ArgumentError
  end

  it 'is_persistent? should be false when category is not persistent' do
    expect(@composition.is_persistent?).to be_falsey
  end

  it 'is_persistent? should be true when category is persistent' do
    category = double(DvCodedText, :value => 'persistent', :defining_code => double(CodePhrase, :code_string => '431'))
    @composition.category = category
    expect(@composition.is_persistent?).to be_truthy
  end

  it 'content should be assigned properly' do
    expect(@composition.content.size).to eq(3)
  end

  it 'context should be assigned properly' do
    expect(@composition.context.location).to eq('lab1')
  end

  it 'auto-wires each content item.parent to self' do
    section = double('Section', :archetype_node_id => 'at0009')
    allow(section).to receive(:parent=)
    composition = Composition.new(:archetype_node_id => 'at0001',
                                  :name => DvText.new(:value => 'composition test'),
                                  :language => double(CodePhrase, :code_string => 'ja'),
                                  :category => double(DvCodedText, :value => 'event', :defining_code => double(CodePhrase, :code_string => '433')),
                                  :territory => double(CodePhrase, :code_string => 'jpn'),
                                  :composer => double(PartyProxy, :external_ref => double(PartyRef, :type => 'ROLE')),
                                  :content => [section])
    expect(section).to have_received(:parent=).with(composition)
  end
end
