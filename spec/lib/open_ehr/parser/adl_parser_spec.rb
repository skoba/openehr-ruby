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

              it 'language = ISO_639-1::en' do
                @en[:language].should == 'ISO_639-1::en'
              end 
            end

          end
        end
      end
    end
  end
end
