require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Ontology

describe ArchetypeTerm do
  before(:each) do
    items = {:text => 'text', :desc => 'description'}
    @archetype_term = ArchetypeTerm.new(:code => 'at0001',
                                        :items => items)
  end

  it 'should be an instance of ArchetypeTerm' do
    @archetype_term.should be_an_instance_of ArchetypeTerm
  end

  it 'code should be assigned properly' do
    @archetype_term.code.should == 'at0001'
  end

  it 'should raise ArgumentError if code is nil' do
    lambda {
      @archetype_term.code = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError if code is empty' do
    lambda {
      @archetype_term.code = ''
    }.should raise_error ArgumentError
  end

  it 'items should be assigned properly' do
    @archetype_term.items[:text].should == 'text'
  end

  it 'keys should be a set of keys of item' do
    @archetype_term.keys.should == Set[:text, :desc]
  end

  it 'keys should be empty if items are nil' do
    @archetype_term.items = nil
    @archetype_term.keys.should == Set.new
  end
end
