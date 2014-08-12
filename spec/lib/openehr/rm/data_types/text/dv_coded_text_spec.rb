require File.dirname(__FILE__) + '/../../../../../spec_helper'

module OpenEHR
  module RM
    module DataTypes
      module Text
        describe DvCodedText do
          let(:dv_coded_text) {
            defining_code = double(CodePhrase)
            allow(defining_code).to receive(:code_string).and_return('Acute myeloid leukemia')
            DvCodedText.new(value: 'C920', defining_code: defining_code) }

          it "should be_an_instance_of DvCodedText" do
            expect(dv_coded_text).to be_an_instance_of DvCodedText
          end

          it 'value should be assigned valid' do
            expect(dv_coded_text.value).to eq('C920')
          end

          it 'defining code string is Acute myeloid leukemia' do
            expect(dv_coded_text.defining_code.code_string).to eq(
              'Acute myeloid leukemia'
            )
          end
        end
      end
    end
  end
end
