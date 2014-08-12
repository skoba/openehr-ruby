require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::Parser

describe ADLParser do
  context 'Language' do
    before(:all) do
      target_adl_file = 'adl-test-entry.archetype_language.test.adl'
      ap = ADLParser.new(ADL14DIR + target_adl_file)
      @archetype = ap.parse
    end

    context 'original language' do
      before(:all) do
        @original_language = @archetype.original_language
      end

      it 'original language is en' do
        expect(@original_language.code_string).to eq('en')
      end

      it 'terminology_id ISO_639-1' do
        expect(@original_language.terminology_id.value).to eq('ISO_639-1')
      end
    end

    context 'translations' do
      before(:all) do
        @translations = @archetype.translations
      end

      it 'translation is not nil' do
        expect(@translations).not_to be_nil
      end

      context 'German translation' do
        before(:all) do
          @de = @translations['de']
        end

        it 'translation is not nil' do
          expect(@de).not_to be_nil
        end

        it 'German code_string is de' do
          expect(@de.language.code_string).to eq('de')
        end

        it 'terminology id is ISO_639-1' do
          expect(@de.language.terminology_id.value).to eq('ISO_639-1')
        end

        it 'accreditation is British Medical Translator id 00400595' do
          expect(@de.accreditation).to eq('British Medical Translator id 00400595')
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

        context 'other_details' do
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
      end

      context 'Russian translation' do
        before(:all) do
          @ru = @translations['ru']
        end

        it 'code is ru' do
          expect(@ru.language.code_string).to eq('ru')
        end

        it 'terminology id is ISO_639-1' do
          expect(@ru.language.terminology_id.value).to eq('ISO_639-1')
        end

        it 'accreditation is Russion Translator id 892230A' do
          expect(@ru.accreditation).to eq('Russion Translator id 892230A')
        end

        context 'author' do
          before(:all) do
            @author = @ru.author
          end

          it 'name is Vladimir Nabokov' do
            expect(@author['name']).to eq('Vladimir Nabokov')
          end

          it 'email is vladimir@something.somewhere.ru' do
            expect(@author['email']).to eq('vladimir@something.somewhere.ru')
          end
        end
      end
    end
  end
end
