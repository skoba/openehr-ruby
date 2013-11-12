require 'spec_helper'

module OpenEHR
  module Parser
    describe OPTParser do
      let(:optparser) { OpenEHR::Parser::OPTParser.new(File.join(File.dirname(__FILE__), './eReferral.opt'))}
      let(:opt) {optparser.parse}

      it 'concept expected to eRefarral' do
        expect(opt.concept).to eq 'eReferral'
      end

      it 'language code string is en' do
        expect(opt.language.code_string).to eq 'en'
      end
      
      it 'template_id expected to e5f533a2-7480-4b53-91f6-9b83433f36ab' do
        expect(opt.template_id.value).to eq 'e5f533a2-7480-4b53-91f6-9b83433f36ab'
      end

      context 'description section' do
        it 'original_author is not specified' do
          expect(opt.description.original_author).to eq 'Not Specified'
        end

        it 'details language terminology is ISO 639-1' do
          expect(opt.description.details[0].language.terminology_id.value).to eq 'ISO_639-1'
        end
      end

      context 'definition section' do
        it 'root node id should be at0000' do
          expect(opt.definition.node_id).to eq 'at0000'
        end

        it 'root rm type name should be COMPOSITION' do
          expect(opt.definition.rm_type_name).to eq 'COMPOSITION'
        end

        it 'root archetype id should be openEHR-EHR-COMPOSITION.referral.v1' do
          expect(opt.definition.archetype_id.value).to eq 'openEHR-EHR-COMPOSITION.referral.v1'
        end

        context 'root cardinality is mandatory' do
          it 'lower limit is 1' do
            expect(opt.definition.occurrences.lower).to eq 1
          end

          it 'upper limit is 1' do
            expect(opt.definition.occurrences.upper).to eq 1
          end

          it 'lower included is true' do
            expect(opt.definition.occurrences.lower_included?).to be_true
          end

          it 'upper included is true' do
            expect(opt.definition.occurrences.upper_included?).to be_true
          end

          it 'lower_unbounded is false' do
            expect(opt.definition.occurrences.lower_unbounded?).to be_false
          end

          it 'upper_unbounded is false' do
            expect(opt.definition.occurrences.upper_unbounded?).to be_false
          end
        end
      end
    end
  end
end
