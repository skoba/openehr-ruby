# coding: utf-8
require 'json'
include OpenEHR::Serializer
OPT_FILE = File.join(File.dirname(__FILE__), '../opt_parser/minimum_template.opt')

describe OPTSerializer do

  subject(:opt) { OPTSerializer.new(OPT_FILE, format: :json) }


  it 'should be an instance of OPTSerializer' do
    expect(opt).to be_an_instance_of OPTSerializer
  end

  it { is_expected.to be_an_instance_of OPTSerializer }

  context 'JSON format' do
    describe 'header' do
      it 's name should be　Problem/Diagnosis' do
        expect(opt.name).to eq 'minimum'
      end

      # The previous expectation here (OPT_HEADER, now removed) described a
      # Composition instance - name/archetype_details/territory/composer -
      # that doesn't exist anywhere in minimum_template.opt (it even named a
      # different archetype_id and template_id); an operational template
      # carries constraints, not instance data like a composer or territory,
      # so header is template-level metadata instead: concept, the root
      # archetype's id, the template's own id, and its language.
      it 'shows header information by JSON' do
        header = JSON.parse(opt.header)
        expect(header).to eq(
          'concept' => 'minimum template',
          'archetype_id' => 'openEHR-EHR-COMPOSITION.minimum.v1',
          'template_id' => 'minimum template',
          'language' => 'ja'
        )
      end
    end

    # context/content are the AOM constraint subtrees for the root
    # archetype's context/content attributes (what the template actually
    # constrains), serialized via JSONSerializer - the same generic
    # reflection walker RMJSONSerializer uses for RM instances.
    it 'shows context information by JSON' do
      context = JSON.parse(opt.context)
      expect(context['_type']).to eq('C_SINGLE_ATTRIBUTE')
      expect(context['rm_attribute_name']).to eq('context')
    end

    it 'shows content infromation by JSON' do
      content = JSON.parse(opt.content)
      expect(content['_type']).to eq('C_MULTIPLE_ATTRIBUTE')
      expect(content['rm_attribute_name']).to eq('content')
    end
  end
end
