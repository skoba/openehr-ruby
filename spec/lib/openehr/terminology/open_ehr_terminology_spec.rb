require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'OpenEHRTerminology' do
  before(:each) do
    @term = OpenEHR::Terminology::OpenEHRTerminology.new
  end

  it 'should parse and return languages' do
    @term.languages[0].should == {'code' => 'af', 'Description' => 'Afrikaans'}
  end

  it 'should parse and return primary rubrics' do
    @term.primary_rubrics[0].should == {'Id' => '0', 'Language' => 'en'}
  end

  it 'should parse and return concepts' do
    @term.concepts[0].should == {'Rubric' => 'self', 'Language' => 'en',
      'ConceptID' => '0'}
  end

  it 'should parse and return groupers' do
    @term.groupers[0].should == {'id' => '0', 'ConceptID' => '154'}
  end

  it 'should parse and return grouped_concepts' do
    @term.grouped_concepts[0].should == {'ChildID' => '0', 'GrouperID' => '1'}
  end

  it 'should parse and return terminology identifiers' do
    @term.terminology_identifiers[0].should ==
      {'VSAB' => 'AIR93', 'Authority' => 'UMLS2003AA',
      'SourceName' => 'AI/RHEUM,1993'}
  end

  it 'should parse and return territory' do
    @term.territories[0].should == 
      {'Text' => 'Afghanistan', 'ThreeLetter'=>'AFG',
      'NumericCode' => '004', 'TwoLetter' => 'AF'}
  end
end
