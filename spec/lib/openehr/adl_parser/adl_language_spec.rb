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

      context 'German translation' do
        before(:all) do
          @de = @translations['de']
        end

        it 'translation is not nil' do
          @de.should_not be_nil
        end

        it 'German code_string is de' do
          @de.language.code_string.should == 'de'
        end

        it 'terminology id is ISO_639-1' do
          @de.language.terminology_id.value.should == 'ISO_639-1'
        end

        it 'accreditation is British Medical Translator id 00400595' do
          @de.accreditation.should == 'British Medical Translator id 00400595'
        end

        context 'author' do
          before(:all) do
            @author = @de.author
          end

          it 'name is Harry Potter' do
            @author['name'].should == 'Harry Potter'
          end

          it 'email is harry@something.somewhere.co.uk' do
            @author['email'].should == 'harry@something.somewhere.co.uk'
          end
        end

        context 'other_details' do
          before(:all) do
            @other_details = @de.other_details
          end

          it 'review 1 is Ron Weasley' do
            @other_details['review 1'].should == 'Ron Weasley'
          end

          it 'review 2 is Rubeus Hagrid' do
            @other_details['review 2'].should == 'Rubeus Hagrid'
          end
        end
      end

      context 'Russian translation' do
        before(:all) do
          @ru = @translations['ru']
        end

        it 'code is ru' do
          @ru.language.code_string.should == 'ru'
        end

        it 'terminology id is ISO_639-1' do
          @ru.language.terminology_id.value.should == 'ISO_639-1'
        end

        it 'accreditation is Russion Translator id 892230A' do
          @ru.accreditation.should == 'Russion Translator id 892230A'
        end

        context 'author' do
          before(:all) do
            @author = @ru.author
          end

          it 'name is Vladimir Nabokov' do
            @author['name'].should == 'Vladimir Nabokov'
          end

          it 'email is vladimir@something.somewhere.ru' do
            @author['email'].should == 'vladimir@something.somewhere.ru'
          end
        end
      end
    end
  end
end
