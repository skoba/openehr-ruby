# coding: utf-8
require_relative  File.dirname(__FILE__) + '/../../../spec_helper'
require_relative File.dirname(__FILE__) + '/../adl_parser/parser_spec_helper'
module OpenEHR
  module RM
    describe Factory do
      describe CompositionFactory do
        
      end

      describe DvBooleanFactory do
        subject { Factory.create('DvBoolean', value: true) }
        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Basic::DvBoolean }
      end

      describe DvStateFactory do
        subject { Factory.create('DV_STATE', value: double(), terminal: true) }
        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Basic::DvState }
      end

      describe DvIdentifierFactory do
        subject { Factory.create('DV_IDENTIFIER',
                                 issuer: 'Ehime univ', assigner: 'Hospital',
                                 id: '012345', type: 'local id') }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Basic::DvIdentifier }
      end

      describe DvTextFactory do
        subject { Factory.create("DvText", value: 'text') }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Text::DvText }
      end

      context "DV_TEXT mapped to camelized RM type" do
        subject { Factory.create('DV_TEXT', value:'text') }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Text::DvText }
      end

      describe TermMappingFactory do
        let(:target) { double() }
        subject { Factory.create('TERM_MAPPING', target: target, match: '=') }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Text::TermMapping }
      end

      describe CodePhraseFactory do
        let(:terminology_id) { double() }
        subject { Factory.create('CODE_PHRASE',
                                 terminology_id: terminology_id,
                                 code_string: 'C890') }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Text::CodePhrase }
      end

      describe DvCodedTextFactory do
        subject { Factory.create('DV_CODED_TEXT', value: 'C089', defining_code: double()) }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Text::DvCodedText }
      end

      describe DvParagraphFactory do
        let(:items) { ['short sentence', 'long sentence']}
        subject { Factory.create('DV_PARAGRAPH', items: items) }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Text::DvParagraph }
      end

      describe DvOrderedFactory do
        subject { Factory.create('DV_ORDERED') }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvOrdered }
      end

      describe DvIntervalFactory do
        subject { Factory.create('DV_INTERVAL', upper: 100, lower: 1) }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvInterval }
      end

      describe ReferenceRangeFactory do
        subject { Factory.create('REFERENCE_RANGE', meaning: 'spec', range: double) }
        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Quantity::ReferenceRange }
      end

      describe DvOrdinalFactory do
        subject { Factory.create('DV_ORDINAL', value: 1, symbol: double()) }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvOrdinal }
      end

      describe DvQuantifiedFactory do
        subject { Factory.create('DV_QUANTIFIED', magnitude: 1) }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvQuantified }
      end

      describe DvAmountFactory do
        subject { Factory.create('DV_AMOUNT', magnitude: 0) }

        it { is_expected.to be_an_instance_of DataTypes::Quantity::DvAmount }
      end

      describe DvQuantityFactory do
        subject { Factory.create("DvQuantity", magnitude: 10, units: 'mg') }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvQuantity }
      end

      describe DvCountFactory do
        subject { Factory.create("DV_COUNT", magnitude: 3) }

        it { is_expected.to be_an_instance_of DataTypes::Quantity::DvCount }
      end

      describe DvProportionFactory do
        subject { Factory.create('DV_PROPORTION', numerator: 2, denominator: 1,
                      type: DataTypes::Quantity::ProportionKind::PK_UNITARY) }

        it { is_expected.to be_an_instance_of DataTypes::Quantity::DvProportion }
      end

      describe DvAbsoluteQuantityFactory do
        subject { Factory.create('DV_ABSOLUTE_QUANTITY', magnitude: 6) }

        it { is_expected.to be_an_instance_of DataTypes::Quantity::DvAbsoluteQuantity }
      end

      describe DvTemporalFactory do
        subject { Factory.create('DV_TEMPORAL', value: '2013-02-20T02:09:30') }

        it { is_expected.to be_an_instance_of DataTypes::Quantity::DateTime::DvTemporal }
      end

      describe DvDateFactory do
        subject { Factory.create("DV_DATE", value: '2013-02-19') }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate }
      end

      describe DvTimeFactory do
        subject { Factory.create('DV_TIME', value: '02:13:39') }

        it { is_expected.to be_an_instance_of DataTypes::Quantity::DateTime::DvTime }
      end

      describe DvDateTimeFactory do
        subject { Factory.create('DV_DATE_TIME', value: '2013-02-21T01:02:23') }

        it { is_expected.to be_an_instance_of DataTypes::Quantity::DateTime::DvDateTime }
      end

      describe DvDurationFactory do
        subject { Factory.create('DV_DURATION', value: 'P1Y2M') }

        it { is_expected.to be_an_instance_of DataTypes::Quantity::DateTime::DvDuration }
      end

      describe DvEncapsulatedFactory do
        subject { Factory.create('DV_ENCAPSULATED', value: 'sample') }

        it { is_expected.to be_an_instance_of DataTypes::Encapsulated::DvEncapsulated }
      end

      describe DvMultimediaFactory do
        subject { media_type = double('media_type')
          allow(media_type).to receive(:code_string).and_return('SVG')
          Factory.create('DV_MULTIMEDIA', value: '<SVG> test </SVG>',
                                 media_type: media_type) }

        it { is_expected.to be_an_instance_of DataTypes::Encapsulated::DvMultimedia }
      end

      describe DvParsableFactory do
        subject { Factory.create('DvParsable', value: 'test', formalism: 'plain/text') }

        it { is_expected.to be_an_instance_of DataTypes::Encapsulated::DvParsable }
      end

      describe DvUriFactory do
        subject { Factory.create('DV_URI', value: 'http://openehr.jp') }

        it { is_expected.to be_an_instance_of DataTypes::URI::DvUri }
      end

      describe DvEhrUriFactory do
        subject { Factory.create('DV_EHR_URI', value: 'ehr://test/87284370-2D4B-4e3d-A3F3-F303D2F4F34B@2005-08-02T04:30:00') }

        it { is_expected.to be_an_instance_of DataTypes::URI::DvEhrUri }
      end

      describe SectionFactory do
        subject { Factory.create('Section',
                                 archetype_node_id: 'at0001',
                                 name: Factory.create('DV_TEXT', value: 'Physical Examination'))}

        it { is_expected.to be_an_instance_of Composition::Content::Navigation::Section }
      end

      describe CompositionFactory do
        let(:params) { JSON.parse(COMPOSITION_JSON) }
        subject { Factory.create('Composition',params: params )}
      end
    end
  end
end

COMPOSITION_JSON=<<END
{
    "name": {
        "_type": "DV_TEXT",
        "value": "Health summary"
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
    "context": {
        "_type": "EVENT_CONTEXT",
        "start_time": {
            "_type": "DV_DATE_TIME",
            "value": "2020-09-22T16:18:51.481222+02:00"
        },
        "setting": {
            "_type": "DV_CODED_TEXT",
            "value": "other care",
            "defining_code": {
                "_type": "CODE_PHRASE",
                "terminology_id": {
                    "_type": "TERMINOLOGY_ID",
                    "value": "openehr"
                },
                "code_string": "238"
            }
        },
        "health_care_facility": {
            "_type": "PARTY_IDENTIFIED",
            "external_ref": {
                "_type": "PARTY_REF",
                "id": {
                    "_type": "GENERIC_ID",
                    "value": "9091",
                    "scheme": "Wako Hospital"
                },
                "namespace": "Wako hospital",
                "type": "PARTY"
            },
            "name": "Wako Hospital"
        },
        "participations": [
            {
                "_type": "PARTICIPATION",
                "function": {
                    "_type": "DV_TEXT",
                    "value": "requester"
                },
                "performer": {
                    "_type": "PARTY_IDENTIFIED",
                    "external_ref": {
                        "_type": "PARTY_REF",
                        "id": {
                            "_type": "GENERIC_ID",
                            "value": "199",
                            "scheme": "Wako Hospital"
                        },
                        "namespace": "Wako hospital",
                        "type": "ANY"
                    },
                    "name": "Dr. Shinji Kobayashi"
                },
                "mode": {
                    "_type": "DV_CODED_TEXT",
                    "value": "face-to-face communication",
                    "defining_code": {
                        "_type": "CODE_PHRASE",
                        "terminology_id": {
                            "_type": "TERMINOLOGY_ID",
                            "value": "openehr"
                        },
                        "code_string": "216"
                    }
                }
            },
            {
                "_type": "PARTICIPATION",
                "function": {
                    "_type": "DV_TEXT",
                    "value": "performer"
                },
                "performer": {
                    "_type": "PARTY_IDENTIFIED",
                    "external_ref": {
                        "_type": "PARTY_REF",
                        "id": {
                            "_type": "GENERIC_ID",
                            "value": "198",
                            "scheme": "Wako Hospital"
                        },
                        "namespace": "Wako hospital",
                        "type": "ANY"
                    },
                    "name": "Nurse 1"
                },
                "mode": {
                    "_type": "DV_CODED_TEXT",
                    "value": "not specified",
                    "defining_code": {
                        "_type": "CODE_PHRASE",
                        "terminology_id": {
                            "_type": "TERMINOLOGY_ID",
                            "value": "openehr"
                        },
                        "code_string": "193"
                    }
                }
            }
        ]
    },
    "content": [
        {
            "_type": "OBSERVATION",
            "name": {
                "_type": "DV_TEXT",
                "value": "Story/History"
            },
            "archetype_details": {
                "_type": "ARCHETYPED",
                "archetype_id": {
                    "_type": "ARCHETYPE_ID",
                    "value": "openEHR-EHR-OBSERVATION.story.v1"
                },
                "rm_version": "1.0.4"
            },
            "archetype_node_id": "openEHR-EHR-OBSERVATION.story.v1",
            "language": {
                "_type": "CODE_PHRASE",
                "terminology_id": {
                    "_type": "TERMINOLOGY_ID",
                    "value": "ISO_639-1"
                },
                "code_string": "ja"
            },
            "encoding": {
                "_type": "CODE_PHRASE",
                "terminology_id": {
                    "_type": "TERMINOLOGY_ID",
                    "value": "IANA_character-sets"
                },
                "code_string": "UTF-8"
            },
            "subject": {
                "_type": "PARTY_SELF"
            },
            "other_participations": [
                {
                    "_type": "PARTICIPATION",
                    "function": {
                        "_type": "DV_TEXT",
                        "value": "requester"
                    },
                    "performer": {
                        "_type": "PARTY_IDENTIFIED",
                        "external_ref": {
                            "_type": "PARTY_REF",
                            "id": {
                                "_type": "GENERIC_ID",
                                "value": "199",
                                "scheme": "Wako Hospital"
                            },
                            "namespace": "Wako hospital",
                            "type": "ANY"
                        },
                        "name": "Dr. Shinji Kobayashi"
                    },
                    "mode": {
                        "_type": "DV_CODED_TEXT",
                        "value": "face-to-face communication",
                        "defining_code": {
                            "_type": "CODE_PHRASE",
                            "terminology_id": {
                                "_type": "TERMINOLOGY_ID",
                                "value": "openehr"
                            },
                            "code_string": "216"
                        }
                    }
                },
                {
                    "_type": "PARTICIPATION",
                    "function": {
                        "_type": "DV_TEXT",
                        "value": "performer"
                    },
                    "performer": {
                        "_type": "PARTY_IDENTIFIED",
                        "external_ref": {
                            "_type": "PARTY_REF",
                            "id": {
                                "_type": "GENERIC_ID",
                                "value": "198",
                                "scheme": "Wako Hospital"
                            },
                            "namespace": "Wako hospital",
                            "type": "ANY"
                        },
                        "name": "Nurse 1"
                    },
                    "mode": {
                        "_type": "DV_CODED_TEXT",
                        "value": "not specified",
                        "defining_code": {
                            "_type": "CODE_PHRASE",
                            "terminology_id": {
                                "_type": "TERMINOLOGY_ID",
                                "value": "openehr"
                            },
                            "code_string": "193"
                        }
                    }
                }
            ],
            "data": {
                "_type": "HISTORY",
                "name": {
                    "_type": "DV_TEXT",
                    "value": "Event Series"
                },
                "archetype_node_id": "at0001",
                "origin": {
                    "_type": "DV_DATE_TIME",
                    "value": "2020-09-22T16:18:51.481222+02:00"
                },
                "events": [
                    {
                        "_type": "POINT_EVENT",
                        "name": {
                            "_type": "DV_TEXT",
                            "value": "Any event"
                        },
                        "archetype_node_id": "at0002",
                        "time": {
                            "_type": "DV_DATE_TIME",
                            "value": "2020-09-22T16:18:51.481222+02:00"
                        },
                        "data": {
                            "_type": "ITEM_TREE",
                            "name": {
                                "_type": "DV_TEXT",
                                "value": "Tree"
                            },
                            "archetype_node_id": "at0003",
                            "items": [
                                {
                                    "_type": "ELEMENT",
                                    "name": {
                                        "_type": "DV_TEXT",
                                        "value": "Story"
                                    },
                                    "archetype_node_id": "at0004",
                                    "value": {
                                        "_type": "DV_TEXT",
                                        "value": "4日前より発熱。解熱せず呼吸器症状悪化"
                                    }
                                },
                                {
                                    "_type": "CLUSTER",
                                    "name": {
                                        "_type": "DV_TEXT",
                                        "value": "Symptom/Sign"
                                    },
                                    "archetype_details": {
                                        "_type": "ARCHETYPED",
                                        "archetype_id": {
                                            "_type": "ARCHETYPE_ID",
                                            "value": "openEHR-EHR-CLUSTER.symptom_sign.v1"
                                        },
                                        "rm_version": "1.0.4"
                                    },
                                    "archetype_node_id": "openEHR-EHR-CLUSTER.symptom_sign.v1",
                                    "items": [
                                        {
                                            "_type": "ELEMENT",
                                            "name": {
                                                "_type": "DV_TEXT",
                                                "value": "Symptom/Sign name"
                                            },
                                            "archetype_node_id": "at0001",
                                            "value": {
                                                "_type": "DV_TEXT",
                                                "value": "咳、鼻水"
                                            }
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                ]
            }
        },
        {
            "_type": "OBSERVATION",
            "name": {
                "_type": "DV_TEXT",
                "value": "Temperature"
            },
            "archetype_details": {
                "_type": "ARCHETYPED",
                "archetype_id": {
                    "_type": "ARCHETYPE_ID",
                    "value": "openEHR-EHR-OBSERVATION.temperature.v1"
                },
                "rm_version": "1.0.4"
            },
            "archetype_node_id": "openEHR-EHR-OBSERVATION.temperature.v1",
            "language": {
                "_type": "CODE_PHRASE",
                "terminology_id": {
                    "_type": "TERMINOLOGY_ID",
                    "value": "ISO_639-1"
                },
                "code_string": "ja"
            },
            "encoding": {
                "_type": "CODE_PHRASE",
                "terminology_id": {
                    "_type": "TERMINOLOGY_ID",
                    "value": "IANA_character-sets"
                },
                "code_string": "UTF-8"
            },
            "subject": {
                "_type": "PARTY_SELF"
            },
            "other_participations": [
                {
                    "_type": "PARTICIPATION",
                    "function": {
                        "_type": "DV_TEXT",
                        "value": "requester"
                    },
                    "performer": {
                        "_type": "PARTY_IDENTIFIED",
                        "external_ref": {
                            "_type": "PARTY_REF",
                            "id": {
                                "_type": "GENERIC_ID",
                                "value": "199",
                                "scheme": "Wako Hospital"
                            },
                            "namespace": "Wako hospital",
                            "type": "ANY"
                        },
                        "name": "Dr. Shinji Kobayashi"
                    },
                    "mode": {
                        "_type": "DV_CODED_TEXT",
                        "value": "face-to-face communication",
                        "defining_code": {
                            "_type": "CODE_PHRASE",
                            "terminology_id": {
                                "_type": "TERMINOLOGY_ID",
                                "value": "openehr"
                            },
                            "code_string": "216"
                        }
                    }
                },
                {
                    "_type": "PARTICIPATION",
                    "function": {
                        "_type": "DV_TEXT",
                        "value": "performer"
                    },
                    "performer": {
                        "_type": "PARTY_IDENTIFIED",
                        "external_ref": {
                            "_type": "PARTY_REF",
                            "id": {
                                "_type": "GENERIC_ID",
                                "value": "198",
                                "scheme": "Wako Hospital"
                            },
                            "namespace": "Wako hospital",
                            "type": "ANY"
                        },
                        "name": "Nurse 1"
                    },
                    "mode": {
                        "_type": "DV_CODED_TEXT",
                        "value": "not specified",
                        "defining_code": {
                            "_type": "CODE_PHRASE",
                            "terminology_id": {
                                "_type": "TERMINOLOGY_ID",
                                "value": "openehr"
                            },
                            "code_string": "193"
                        }
                    }
                }
            ],
            "data": {
                "_type": "HISTORY",
                "name": {
                    "_type": "DV_TEXT",
                    "value": "Event Series"
                },
                "archetype_node_id": "at0001",
                "origin": {
                    "_type": "DV_DATE_TIME",
                    "value": "2020-09-22T16:18:51.481222+02:00"
                },
                "events": [
                    {
                        "_type": "POINT_EVENT",
                        "name": {
                            "_type": "DV_TEXT",
                            "value": "Any event"
                        },
                        "archetype_node_id": "at0002",
                        "time": {
                            "_type": "DV_DATE_TIME",
                            "value": "2020-09-22T16:18:51.481222+02:00"
                        },
                        "data": {
                            "_type": "ITEM_LIST",
                            "name": {
                                "_type": "DV_TEXT",
                                "value": "Single"
                            },
                            "archetype_node_id": "at0003",
                            "items": [
                                {
                                    "_type": "ELEMENT",
                                    "name": {
                                        "_type": "DV_TEXT",
                                        "value": "Temperature"
                                    },
                                    "archetype_node_id": "at0004",
                                    "value": {
                                        "_type": "DV_QUANTITY",
                                        "magnitude": 37.0,
                                        "units": "°C"
                                    }
                                }
                            ]
                        }
                    }
                ]
            }
        }
    ]
}
END
