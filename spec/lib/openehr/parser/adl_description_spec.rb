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
        @original_author["name"].should == 'Sam Heard'
      end

      it 'organisation is Ocean Informatics' do
        @original_author["organisation"].should == 'Ocean Informatics'
      end

      it 'date is 23/04/2006' do
        @original_author["date"].should == '23/04/2006'
      end

      it 'email is sam.heard@oceaninformatics.biz' do
        @original_author["email"].should == 'sam.heard@oceaninformatics.biz'
      end
    end

    context 'details' do
      before(:all) do
        @details = @description.details
      end

      it 'details is not nil' do
        @details.should_not be_nil
      end

      it 'details size is 1' do
        @details.size.should be 1
      end

      context 'item' do
        before(:all) do
          @item = @details['en']
        end

        it 'is not nil' do
          @item.should_not be_nil
        end

        it 'language is en' do
          @item.language.code_string.should == 'en'
        end

        it 'terminolopgy id is ISO_639-1' do
          @item.language.terminology_id.value.should == 'ISO_639-1'
        end

        it 'purpose is For recording...' do
          @item.purpose.should == "For recording a problem, condition " +
            "or issue that has ongoing significance to the person's health."
        end

        it 'use is Used for recording any....' do
          @item.use.should == "Used for recording any problem, " + 
            "present or past - so is used for recording past " +
            "history as well as current problems. Used with changed " +
            "'Subject of care' for recording problems of relatives " +
            "and so for family history."
        end

        it 'misuse is Use specialisations for ...' do
          @item.misuse.should == "Use specialisations for medical " +
            "diagnoses, 'openEHR-EHR-EVALUATION.problem-diagnosis' and " +
            "histological diagnoses 'openEHR-EHR-EVALUATION.problem-" +
            "diagnosis-histological'"
        end

        it 'copyright is copyright (c) 2004 The openEHR Foundation' do
          @item.copyright.should == 'copyright (c) 2004 The openEHR Foundation'
        end

        it 'keywords are issue and condition' do
          @item.keywords.should == ['issue', 'condition']
        end

        context 'original resource uri' do
          before(:all) do
            @original_resource_uri = @item.original_resource_uri
          end

          it 'ligne guide is http://guidelines.are.us/wherever/fr' do
            @original_resource_uri['ligne guide'].should ==
              'http://guidelines.are.us/wherever/fr'
          end

          it 'medline is http://some%20medline%20ref' do
            @original_resource_uri['medline'].should == 'http://some%20medline%20ref'
          end
        end
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

    context 'other details' do
      before(:all) do
        @other_details = @description.other_details
      end

      it 'other 1 is details 1' do
        @other_details['other 1'].should == 'details 1'
      end

      it 'other 2 is detals 2' do
        @other_details['other 2'].should == 'details 2'
      end
    end
  end

  context 'failed for empty other contributors' do
    before(:all) do
      adl_dir = File.dirname(__FILE__) + '/adl14/'
      @ap = ADLParser.new(adl_dir + 'adl-test-entry.archetype_description2.test.adl')
    end

    it 'fails empty other comtributors' do
      @ap.parse.should raise_error
    end
  end
end
