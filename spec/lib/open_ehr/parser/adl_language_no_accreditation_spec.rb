require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::Parser

describe ADLParser do
  context 'Language no accrediition' do
    before(:all) do
      TARGET_ADL_FILE = 'adl-test-entry.archetype_language_no_accreditation.test.adl'
      ap = ADLParser.new(ADL14DIR + TARGET_ADL_FILE)
      archetype = ap.parse
      @translations = archetype.translations
    end

    it 'exists' do
      @translations.should_not be_nil
    end

    context 'German translation' do
      before(:all) do
        @de = @translations['de']
      end

      it 'exists' do
        @de.should_not be_nil
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

      context 'accreditation' do
        it 'not exist' do
          @de.accreditation.should be_nil
        end
      end

      context 'other details' do
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
  end
end
