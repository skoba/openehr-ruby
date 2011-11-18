require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser

describe ADLParser do
  context 'Description' do
    before(:all) do
      adl_dir = File.dirname(__FILE__) + '/adl14/'
      ap = ADLParser.new(adl_dir + 'adl-test-entry.archetype_description.test.adl')
      archetype = ap.parse
      @description = archetype.description
    end

    it 'description is not null' do
      @description.should_not be_nil
    end

    it 'lifecycle state is AuthorDraft' do
      @description.lifecycle_state.should == 'AuthorDraft'
    end

    it 'resource package uri is www.aihw.org.au/data_sets/diabetic_archetypes.html' do
      @description.resource_package_uri.should == 'www.aihw.org.au/data_sets/diabetic_archetypes.html'
    end

    context 'original author' do
      before(:all) do
        @original_author = @description.original_author
      end

      it 'name is Sam Heard' do
        @original_author[:name].should == 'Sam Heard'
      end

      it 'organisation is Ocean Informatics' do
        @original_author[:organisation].should == 'Ocean Informatics'
      end

      it 'date is 23/04/2006' do
        @original_author[:date].should == '23/04/2006'
      end

      it 'email is sam.heard@oceaninformatics.biz' do
        @original_author[:email].should == 'sam.heard@oceaninformatics.biz'
      end
    end

    context 'other contributors' do
      before(:all) do
        @other_contributors = @description.other_contributors
      end

      it 'other contrubutor(s) are not nil' do
        @other_contributors.should_not be_nil
      end

      it 'other contributor(s) is one' do
        @other_contributors.size.should be 1
      end

      it 'other_contributor(s) is Ian McNicoll, MD' do
        @other_contributors[0].should == 'Ian McNicoll, MD'
      end
    end
  end
end
