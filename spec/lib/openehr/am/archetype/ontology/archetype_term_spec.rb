require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Ontology

describe ArchetypeTerm do
  before(:each) do
    items = {'text' => 'text', 'description' => 'description'}
    @archetype_term = ArchetypeTerm.new(:code => 'at0001',
                                        :items => items)
  end

  it 'should be an instance of ArchetypeTerm' do
    expect(@archetype_term).to be_an_instance_of ArchetypeTerm
  end

  it 'code should be assigned properly' do
    expect(@archetype_term.code).to eq('at0001')
  end

  it 'should raise ArgumentError if code is nil' do
    expect {
      @archetype_term.code = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError if code is empty' do
    expect {
      @archetype_term.code = ''
    }.to raise_error ArgumentError
  end

  it 'items should be assigned properly' do
    expect(@archetype_term.items['text']).to eq('text')
  end

  it 'keys should be a set of keys of item' do
    expect(@archetype_term.keys).to eq(Set['text', 'description'])
  end

  it 'keys should be empty if items are nil' do
    @archetype_term.items = nil
    expect(@archetype_term.keys).to eq(Set.new)
  end
end
