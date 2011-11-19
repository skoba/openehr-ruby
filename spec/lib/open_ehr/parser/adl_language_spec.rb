require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::Parser

describe ADLParser do
  context 'Language' do
    before(:all) do
      ap = ADLParser.new(ADL14DIR + 'adl-test-entry.archetype_language.test.adl')
      @archetype = ap.parse
    end

    context 'original language' do
      before(:all) do
        @original_language = @archetype.original_language
      end

      it 'original language is en' do
        @original_language.code_string.should == 'en'
      end

      it 'terminology_id ISO_639-1' do
        @original_language.terminology_id.value.should == 'ISO_639-1'
      end
    end

    context 'translations' do
      before(:all) do
        @translations = @archetype.translations
      end

      it 'translation is not nil' do
        @translations.should_not be_nil
      end
      
    end
  end
end
