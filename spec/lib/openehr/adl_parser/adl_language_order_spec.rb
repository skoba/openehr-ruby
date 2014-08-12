require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::Parser

describe ADLParser do
  context 'Language order of translation details' do
    before(:all) do
      target_adl_file = 'adl-test-entry.archetype_language_order_of_translation_details.test.adl'
      ap = ADLParser.new(ADL14DIR + '/' + target_adl_file)
      archetype = ap.parse
      @translations = archetype.translations
    end

    it 'translation is not nil' do
      expect(@translations).not_to be_nil
    end

    context 'German translation' do
      before(:all) do
        @de = @translations['de']
      end

      it 'exists' do
        expect(@de).not_to be_nil
      end

      context 'author' do
        before(:all) do
          @author = @de.author
        end

        it 'exists' do
          expect(@author).not_to be_nil
        end

        it 'name is Harry Potter' do
          expect(@author['name']).to eq('Harry Potter')
        end

        it 'email is harry@something.somewhere.co.uk' do
          expect(@author['email']).to eq('harry@something.somewhere.co.uk')
        end
      end

      it 'accreditation is Seven OWLs at Hogwards' do
        expect(@de.accreditation).to eq('Seven OWLs at Hogwards')
      end

      context 'other details' do
        before(:all) do
          @other_details = @de.other_details
        end

        it 'review 1 is Ron Weasley' do
          expect(@other_details['review 1']).to eq('Ron Weasley')
        end

        it 'review 2 is Rubeus Hagrid' do
          expect(@other_details['review 2']).to eq('Rubeus Hagrid')
        end
      end

      it 'language code is de' do
        expect(@de.language.code_string).to eq('de')
      end
    end
  end
end
