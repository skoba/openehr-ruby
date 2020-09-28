# coding: utf-8
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

      xit 'shows header information by JSON' do
        expect(opt.header).to eq OPT_HEADER
      end
    end
    
    it 'shows context information by JSON'

    it 'shows content infromation by JSON'
  end  
end

OPT_HEADER =<<END
    "name": {
        "_type": "DV_TEXT",
        "value": "Problem/Diagnosis"
    },
    "archetype_details": {
        "_type": "ARCHETYPED",
        "archetype_id": {
            "_type": "ARCHETYPE_ID",
            "value": "openEHR-EHR-COMPOSITION.health_summary.v1"
        },
        "template_id": {
                "_type": "TEMPLATE_ID",
                "value": "symptom_screening"
            },
            "rm_version": "1.0.4"
        },
        "archetype_node_id": "openEHR-EHR-COMPOSITION.health_summary.v1",
        "language": {
            "_type": "CODE_PHRASE",
            "terminology_id": {
                "_type": "TERMINOLOGY_ID",
                "value": "ISO_639-1"
            },
            "code_string": "en"
        },
        "territory": {
            "_type": "CODE_PHRASE",
            "terminology_id": {
                "_type": "TERMINOLOGY_ID",
                "value": "ISO_3166-1"
            },
            "code_string": "JP"
        },
        "category": {
            "_type": "DV_CODED_TEXT",
            "value": "event",
            "defining_code": {
                "_type": "CODE_PHRASE",
                "terminology_id": {
                    "_type": "TERMINOLOGY_ID",
                    "value": "openehr"
                },
                "code_string": 433
            }
        },
        "composer": {
            "_type": "PARTY_IDENTIFIED",
            "name": "Shinji Kobayashi"
        },

END
