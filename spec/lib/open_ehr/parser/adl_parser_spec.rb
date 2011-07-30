require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser

describe ADLParser do

  before (:all) do
    @adl_dir = File.dirname(__FILE__)+'/adl/'
  end

  context 'openEHR-EHR-SECTION-summary.v1.adl' do
    before(:all) do
      @ap = OpenEHR::Parser::ADLParser.new(@adl_dir + 'openEHR-EHR-SECTION.summary.v1.adl')
    end

    it 'is an instance fo ADLParser' do
      @ap.should be_an_instance_of ADLParser
    end

    context 'openEHR-EHR-SECTION.summary.v1 parse' do
      context 'ADL parser generates archetype from ADL' do
        before(:all) do
          @archetype = @ap.parse
        end

        it 'archetype_id should be openEHR-EHR-SECTION-summary' do
          @archetype.archetype_id.should == 'openEHR-EHR-SECTION.summary.v1'
        end

        it 'adl_version should be 1.4' do
          @archetype.adl_version.should == '1.4'
        end

        it 'concept should be at0000]' do
          @archetype.concept.should == 'at0000'
        end

        it 'original language is ISO_639-1::en' do
          @archetype.original_language.should == 'ISO_639-1::en'
        end

        context 'description' do
          before(:all) do
            @description = @archetype.description
          end

          context 'original author' do
            before(:all) do
              @original_author = @description[:original_author]
            end

            it 'name is Sam Heard' do
              @original_author[:name].should == 'Sam Heard'
            end

            it 'organisation is Ocean Informatics' do
              @original_author[:organisation].should == 'Ocean Informatics'
            end

            it 'date is 9/01/2007' do
              @original_author[:date].should == '9/01/2007'
            end

            it 'email is sam.heard@oceaninformatics.biz' do
              @original_author[:email].should == 'sam.heard@oceaninformatics.biz'
            end
          end

          context 'details' do
            before(:all) do
              @details = @description[:details]
            end

            context 'en details' do
              before(:all) do
                @en = @details[:en]
              end

              it 'language is ISO_639-1::en' do
                @en[:language].should == 'ISO_639-1::en'
              end 

              it 'purpose is A heading...' do
                @en[:purpose].should == "A heading containing summary information based on particular evaluation entries"
              end

              it 'use is A heading for...' do
                @en[:use].should == "A heading for organising clinical data under a heading of summary"
              end

              it 'keywords are review, conclusions, risk' do
                @en[:keywords].should == ['review', 'conclusions', 'risk']
              end

              it 'misuse should empty' do
                @en[:misuse].should == ''
              end
            end

            it 'lifecycle_state is Initial' do
              @description[:lifecycle_state].should == 'Initial'
            end

            it 'other_contributors is nil' do
              @description[:other_contributors].should be_nil
            end
          end # of details
        end # of description

        context 'definition section' do
          before(:all) do
            @definition = @archetype.definition
          end

          it 'rm_type is SECTION' do
            @definition[:rm_type_name].should == 'SECTION'
          end

          it 'node_id is at0000' do
            @definition[:node_id].should == 'at0000'
          end

          it 'path is /' do
            @definition[:path].should == '/'
          end

          it 'not any allowed' do
            @definition[:children][:any_allowed].should == false
          end

          it 'rm_attribute_name is items' do
            @definition[:children][:rm_attribute_name].should == 'items'
          end
        end #definition
      end
    end
  end
end
