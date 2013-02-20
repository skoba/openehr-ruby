require File.dirname(__FILE__) + '/../../../../../spec_helper'

module OpenEHR
  module RM
    module DataTypes
      module Text
        describe DvCodedText do
          let(:dv_coded_text) {
            defining_code = double(CodePhrase)
            defining_code.stub(:code_string).and_return('Acute myeloid leukemia')
            DvCodedText.new(value: 'C920', defining_code: defining_code) }

          it "should be_an_instance_of DvCodedText" do
            dv_coded_text.should be_an_instance_of DvCodedText
          end

          it 'value should be assigned valid' do
            dv_coded_text.value.should == 'C920'
          end

          it 'defining code string is Acute myeloid leukemia' do
            dv_coded_text.defining_code.code_string.should ==
              'Acute myeloid leukemia'
          end
        end
      end
    end
  end
end
