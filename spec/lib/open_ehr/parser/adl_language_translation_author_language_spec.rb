require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::Parser

describe ADLParser do
  context 'Language author parsing behavior' do
    before(:all) do
      TARGET_ADL_FILE = 'adl-test-entry.translations_author_language.test.adl'
      ap = ADLParser.new(ADL14DIR + TARGET_ADL_FILE)
      archetype = ap.parse
      @translations = archetype.translations
    end

    it 'translations exists' do
      @translations.should_not be_nil
    end

    context 'German translation' do
      before(:all) do
        @de = @translations['de']
      end

      it 'exists' do
        @de.should_not be_nil
      end

      it 'language code string is de' do
        @de.language.code_string.should == 'de'
      end

      context 'author' do
        before(:all) do
          @author = @de.author
        end

        it 'exists' do
          @author.should_not be_nil
        end

        it 'name is Harry Potter' do
          @author['name'].should == 'Harry Potter'
        end

        it 'email is harry@something.somewhere.co.uk' do
          @author['email'].should == 'harry@something.somewhere.co.uk'
        end
      end
    end
  end
end
