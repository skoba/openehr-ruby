require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::Parser

describe ADLParser do
  context 'Language author parsing behavior' do
    before(:all) do
      TARGET_ADL_FILE = 'adl-test-entry.translations_language_author.test.adl'
      ap = ADLParser.new(ADL14DIR + TARGET_ADL_FILE)
      archetype = ap.parse
      @translations = archetype.translations
    end

    it 'translations exists' do
      expect(@translations).not_to be_nil
    end

    context 'German translation' do
      before(:all) do
        @de = @translations['de']
      end

      it 'exists' do
        expect(@de).not_to be_nil
      end

      it 'language code string is de' do
        expect(@de.language.code_string).to eq('de')
      end

      context 'author' do
        before(:all) do
          @author = @de.author
        end

        it 'name is Harry Potter' do
          expect(@author['name']).to eq('Harry Potter')
        end

        it 'email is harry@something.somewhere.co.uk' do
          expect(@author['email']).to eq('harry@something.somewhere.co.uk')
        end
      end
    end
  end
end
