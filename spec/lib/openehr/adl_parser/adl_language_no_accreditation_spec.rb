require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::Parser

describe ADLParser do
  context 'Language no accrediition' do
    before(:all) do
      target_adl_file = 'adl-test-entry.archetype_language_no_accreditation.test.adl'
      ap = ADLParser.new(ADL14DIR + target_adl_file)
      archetype = ap.parse
      @translations = archetype.translations
    end

    it 'exists' do
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

      context 'accreditation' do
        it 'not exist' do
          expect(@de.accreditation).to be_nil
        end
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
    end
  end
end
