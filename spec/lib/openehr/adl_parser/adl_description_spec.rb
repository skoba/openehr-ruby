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
      expect(@description).not_to be_nil
    end

    it 'lifecycle state is AuthorDraft' do
      expect(@description.lifecycle_state).to eq('AuthorDraft')
    end
    it 'resource package uri is www.aihw.org.au/data_sets/diabetic_archetypes.html' do
      expect(@description.resource_package_uri).to eq('www.aihw.org.au/data_sets/diabetic_archetypes.html')
    end

    context 'original author' do
      before(:all) do
        @original_author = @description.original_author
      end

      it 'name is Sam Heard' do
        expect(@original_author["name"]).to eq('Sam Heard')
      end

      it 'organisation is Ocean Informatics' do
        expect(@original_author["organisation"]).to eq('Ocean Informatics')
      end

      it 'date is 23/04/2006' do
        expect(@original_author["date"]).to eq('23/04/2006')
      end

      it 'email is sam.heard@oceaninformatics.biz' do
        expect(@original_author["email"]).to eq('sam.heard@oceaninformatics.biz')
      end
    end

    context 'details' do
      before(:all) do
        @details = @description.details
      end

      it 'details is not nil' do
        expect(@details).not_to be_nil
      end

      it 'details size is 1' do
        expect(@details.size).to be 1
      end

      context 'item' do
        before(:all) do
          @item = @details['en']
        end

        it 'is not nil' do
          expect(@item).not_to be_nil
        end

        it 'language is en' do
          expect(@item.language.code_string).to eq('en')
        end

        it 'terminolopgy id is ISO_639-1' do
          expect(@item.language.terminology_id.value).to eq('ISO_639-1')
        end

        it 'purpose is For recording...' do
          expect(@item.purpose).to eq("For recording a problem, condition " +
            "or issue that has ongoing significance to the person's health.")
        end

        it 'use is Used for recording any....' do
          expect(@item.use).to eq("Used for recording any problem, " + 
            "present or past - so is used for recording past " +
            "history as well as current problems. Used with changed " +
            "'Subject of care' for recording problems of relatives " +
            "and so for family history.")
        end

        it 'misuse is Use specialisations for ...' do
          expect(@item.misuse).to eq("Use specialisations for medical " +
            "diagnoses, 'openEHR-EHR-EVALUATION.problem-diagnosis' and " +
            "histological diagnoses 'openEHR-EHR-EVALUATION.problem-" +
            "diagnosis-histological'")
        end

        it 'copyright is copyright (c) 2004 The openEHR Foundation' do
          expect(@item.copyright).to eq('copyright (c) 2004 The openEHR Foundation')
        end

        it 'keywords are issue and condition' do
          expect(@item.keywords).to eq(['issue', 'condition'])
        end

        context 'original resource uri' do
          before(:all) do
            @original_resource_uri = @item.original_resource_uri
          end

          it 'ligne guide is http://guidelines.are.us/wherever/fr' do
            expect(@original_resource_uri['ligne guide']).to eq(
              'http://guidelines.are.us/wherever/fr'
            )
          end

          it 'medline is http://some%20medline%20ref' do
            expect(@original_resource_uri['medline']).to eq('http://some%20medline%20ref')
          end
        end
      end
    end

    context 'other contributors' do
      before(:all) do
        @other_contributors = @description.other_contributors
      end

      it 'other contrubutor(s) are not nil' do
        expect(@other_contributors).not_to be_nil
      end

      it 'other contributor(s) is one' do
        expect(@other_contributors.size).to be 1
      end

      it 'other_contributor(s) is Ian McNicoll, MD' do
        expect(@other_contributors[0]).to eq('Ian McNicoll, MD')
      end
    end

    context 'other details' do
      before(:all) do
        @other_details = @description.other_details
      end

      it 'other 1 is details 1' do
        expect(@other_details['other 1']).to eq('details 1')
      end

      it 'other 2 is detals 2' do
        expect(@other_details['other 2']).to eq('details 2')
      end
    end
  end

  # context 'failed for empty other contributors' do
  #   before(:all) do
  #     adl_dir = File.dirname(__FILE__) + '/adl14/'
  #     @ap = ADLParser.new(adl_dir + 'adl-test-entry.archetype_description2.test.adl')
  #   end

  #   it 'fails empty other comtributors' do
  #     expect { @ap.parse }.to raise_error ParseError
  #   end
  # end
end
