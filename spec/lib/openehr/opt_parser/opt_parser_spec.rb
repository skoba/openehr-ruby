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

        it 'root path is /' do
          expect(opt.definition.path).to eq '/' #[openEHR-EHR-COMPOSITION.referral.v1]'
        end

        it 'root rm type name should be COMPOSITION' do
          expect(opt.definition.rm_type_name).to eq 'COMPOSITION'
        end

        it 'root archetype id should be openEHR-EHR-COMPOSITION.referral.v1' do
          expect(opt.definition.archetype_id.value).to eq 'openEHR-EHR-COMPOSITION.referral.v1'
        end

        describe 'root cardinality is mandatory' do
          it 'lower limit is 1' do
            expect(opt.definition.occurrences.lower).to eq 1
          end

          it 'upper limit is 1' do
            expect(opt.definition.occurrences.upper).to eq 1
          end

          it 'lower included is true' do
            expect(opt.definition.occurrences.lower_included?).to be_truthy
          end

          it 'upper included is true' do
            expect(opt.definition.occurrences.upper_included?).to be_truthy
          end

          it 'lower_unbounded is false' do
            expect(opt.definition.occurrences.lower_unbounded?).to be_falsey
          end

          it 'upper_unbounded is false' do
            expect(opt.definition.occurrences.upper_unbounded?).to be_falsey
          end
        end


        it 'root attributes size is 3' do
          expect(opt.definition.attributes.size).to eq 3
        end

        describe 'category attribute' do
          let(:category) {opt.definition.attributes[0]}

          it 'rm attribute name is category' do
            expect(category.rm_attribute_name).to eq 'category'
          end

          it 'has 1 child' do
            expect(category.children.size).to eq 1
          end

          context 'children' do
            let(:child) {category.children[0]}

            it 'rm_type_name is DV_CODED_TEXT' do
              expect(child.rm_type_name).to eq 'DV_CODED_TEXT'
            end

            it 'node_id is at0000' do
              expect(child.node_id).to eq 'at0000'
            end

            context 'occurrence' do
              let(:occurrences) {child.occurrences}

              it 'lower is 1' do
                expect(occurrences.lower).to eq 1
              end

              it 'upper is 1' do
                expect(occurrences.upper).to eq 1
              end

              it 'is lower_included' do
                expect(occurrences).to be_lower_included
              end

              it 'is upper included' do
                expect(occurrences).to be_upper_included
              end

              it 'is not lower unbounded' do
                expect(occurrences).not_to be_lower_unbounded
              end

              it 'is not upper unbounded' do
                expect(occurrences).not_to be_upper_unbounded
              end
            end

            context 'defining_code' do
              let(:defining_code) {child.attributes[0]}

              it 'rm_attribute_name is defining_code' do
                expect(defining_code.rm_attribute_name).to eq 'defining_code'
              end
            end
          end

          context 'existence' do
            it '1 at minimum' do
              expect(category.existence.lower).to eq 1
            end

            it '1 at maximum' do
              expect(category.existence.upper).to eq 1
            end

            it 'lower included' do
              expect(category.existence).to be_lower_included
            end

            it 'upper inluded' do
              expect(category.existence).to be_upper_included
            end
          end
        end
      end
    end
  end
end
