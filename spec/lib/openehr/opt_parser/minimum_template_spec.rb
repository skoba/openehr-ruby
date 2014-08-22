describe 'minimum_template' do
  let(:optparser) { OpenEHR::Parser::OPTParser.new(File.join(File.dirname(__FILE__), '/minimum_template.opt'))}
  let(:opt) {optparser.parse}

  it 'concept is minimum template' do
    expect(opt.concept).to eq 'minimum template'
  end

  it 'template_id is minimum template' do
    expect(opt.template_id.value).to eq 'minimum template'
  end

  it 'template uid is assigned' do
    expect(opt.uid.value).to eq '199f6890-5c06-4cb2-92de-422848ffe3a8'
  end

  it 'language is ja' do
    expect(opt.language.code_string).to eq 'ja'
  end

  context 'definiition' do
    it 'definition root is COMPOSITION' do
      expect(opt.definition.rm_type_name).to eq 'COMPOSITION'
    end
    
    it 'node_id is at0000' do
      expect(opt.definition.node_id).to eq 'at0000'
    end
    
    it 'root path is /[openEHR-EHR-COMPOSITION.minimum.v1]' do
      expect(opt.definition.path).to eq '/[openEHR-EHR-COMPOSITION.minimum.v1]'
    end
  end

  describe 'component_terminologies' do
    context 'root component' do
      it 'component_terminologies are hash of archetype and terminologies' do
        expect(opt.component_terminologies).to have_key 'openEHR-EHR-COMPOSITION.minimum.v1'
      end

      context 'term_definitions' do
        let(:term_definitions) { opt.component_terminologies['openEHR-EHR-COMPOSITION.minimum.v1']}

        it 'archetype have 3 items' do
          expect(term_definitions).to have(3).items
        end

        it 'is an array' do
          expect(term_definitions).to be_an_instance_of Array
        end

        it 'is included an instance of ArchetypeTerm' do
          expect(term_definitions).to include an_instance_of OpenEHR::AM::Archetype::Terminology::ArchetypeTerm
        end

        it 'is expected to contain valid codes' do
          codes = term_definitions.map{|term| term.code}
          expect(codes).to contain_exactly 'at0000', 'at0001', 'at0002'
        end

        context 'at0000 term' do
          let(:term) { term_definitions[0] }

          it 'code is at0000' do
            expect(term.code).to eq 'at0000'
          end

          it 'item has text' do
            expect(term.items).to have_key 'text'
          end

          it 'text associate Minimum' do
            expect(term.items['text']).to eq 'Minimum'
          end

          it 'description associate mimimum set for ' do
            expect(term.items['description']).to eq 'minimum set for '
          end
        end
      end

      context ''
    end
  end
end
