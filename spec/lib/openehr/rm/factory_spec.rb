# coding: utf-8
require_relative  File.dirname(__FILE__) + '/../../../spec_helper'
require_relative File.dirname(__FILE__) + '/../adl_parser/parser_spec_helper'
module OpenEHR
  module RM
    describe Factory do
      describe DvBooleanFactory do
        subject { Factory.create('DV_BOOLEAN', value: true) }
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

      context "DV_TEXT mapped to camelized RM type" do
        subject { Factory.create('DV_TEXT', value: 'text') }

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
        subject { Factory.create('DV_QUANTITY', magnitude: 10, units: 'mg') }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvQuantity }
      end

      describe DvCountFactory do
        subject { Factory.create('DV_COUNT', magnitude: 3) }

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
        subject { Factory.create('DV_PARSABLE', value: 'test', formalism: 'plain/text') }

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

      describe TermMappingFactory do
        subject { Factory.create('TERM_MAPPING', target: double(), match: '=') }
        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Text::TermMapping }
      end

      describe ElementFactory do
        subject {
          Factory.create('ELEMENT', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'Systolic'),
                         value: Factory.create('DV_QUANTITY', magnitude: 120, units: 'mm[Hg]'))
        }
        it { is_expected.to be_an_instance_of DataStructures::ItemStructure::Representation::Element }
      end

      describe ItemTreeFactory do
        subject {
          Factory.create('ITEM_TREE', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'tree'))
        }
        it { is_expected.to be_an_instance_of DataStructures::ItemStructure::ItemTree }
      end

      describe ItemListFactory do
        subject {
          Factory.create('ITEM_LIST', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'list'))
        }
        it { is_expected.to be_an_instance_of DataStructures::ItemStructure::ItemList }
      end

      describe ItemSingleFactory do
        subject {
          Factory.create('ITEM_SINGLE', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'single'),
                         item: double())
        }
        it { is_expected.to be_an_instance_of DataStructures::ItemStructure::ItemSingle }
      end

      describe ItemTableFactory do
        subject {
          Factory.create('ITEM_TABLE', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'table'))
        }
        it { is_expected.to be_an_instance_of DataStructures::ItemStructure::ItemTable }
      end

      describe HistoryFactory do
        subject {
          Factory.create('HISTORY', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'history'),
                         origin: Factory.create('DV_DATE_TIME', value: '2020-01-01T00:00:00'))
        }
        it { is_expected.to be_an_instance_of DataStructures::History::History }
      end

      describe EventFactory do
        subject {
          Factory.create('EVENT', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'event'),
                         time: Factory.create('DV_DATE_TIME', value: '2020-01-01T00:00:00'),
                         data: double())
        }
        it { is_expected.to be_an_instance_of DataStructures::History::Event }
      end

      describe PointEventFactory do
        subject {
          Factory.create('POINT_EVENT', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'point event'),
                         time: Factory.create('DV_DATE_TIME', value: '2020-01-01T00:00:00'),
                         data: double())
        }
        it { is_expected.to be_an_instance_of DataStructures::History::PointEvent }
      end

      describe IntervalEventFactory do
        subject {
          Factory.create('INTERVAL_EVENT', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'interval event'),
                         time: Factory.create('DV_DATE_TIME', value: '2020-01-01T00:00:00'),
                         data: double(), width: Factory.create('DV_DURATION', value: 'PT1H'),
                         math_function: double())
        }
        it { is_expected.to be_an_instance_of DataStructures::History::IntervalEvent }
      end

      describe ClusterFactory do
        subject {
          Factory.create('CLUSTER', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'cluster'))
        }
        it { is_expected.to be_an_instance_of DataStructures::ItemStructure::Representation::Cluster }
      end

      describe EvaluationFactory do
        subject {
          Factory.create('EVALUATION', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'evaluation'),
                         language: double(code_string: 'en'), encoding: double(code_string: 'UTF-8'),
                         subject: double(), data: double())
        }
        it { is_expected.to be_an_instance_of Composition::Content::Entry::Evaluation }
      end

      describe InstructionFactory do
        subject {
          Factory.create('INSTRUCTION', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'instruction'),
                         language: double(code_string: 'en'), encoding: double(code_string: 'UTF-8'),
                         subject: double(), narrative: double())
        }
        it { is_expected.to be_an_instance_of Composition::Content::Entry::Instruction }
      end

      describe ActionFactory do
        subject {
          Factory.create('ACTION', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'action'),
                         language: double(code_string: 'en'), encoding: double(code_string: 'UTF-8'),
                         subject: double(), time: double(), description: double(),
                         ism_transition: double(current_state: double, transition: double))
        }
        it { is_expected.to be_an_instance_of Composition::Content::Entry::Action }
      end

      describe ActivityFactory do
        subject {
          Factory.create('ACTIVITY', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'activity'),
                         description: double(), timing: double(), action_archetype_id: 'at0002')
        }
        it { is_expected.to be_an_instance_of Composition::Content::Entry::Activity }
      end

      describe AdminEntryFactory do
        subject {
          Factory.create('ADMIN_ENTRY', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'admin entry'),
                         language: double(code_string: 'en'), encoding: double(code_string: 'UTF-8'),
                         subject: double(), data: double())
        }
        it { is_expected.to be_an_instance_of Composition::Content::Entry::AdminEntry }
      end

      describe InstructionDetailsFactory do
        subject { Factory.create('INSTRUCTION_DETAILS', instruction_id: double(), activity_id: 'at0002') }
        it { is_expected.to be_an_instance_of Composition::Content::Entry::InstructionDetails }
      end

      describe IsmTransitionFactory do
        subject {
          Factory.create('ISM_TRANSITION',
                         current_state: double(defining_code: double(code_string: '245')),
                         transition: double(defining_code: double(code_string: '523')))
        }
        it { is_expected.to be_an_instance_of Composition::Content::Entry::IsmTransition }
      end

      describe GenericEntryFactory do
        subject {
          Factory.create('GENERIC_ENTRY', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'generic entry'), data: double())
        }
        it { is_expected.to be_an_instance_of Integration::GenericEntry }
      end

      describe PartySelfFactory do
        subject { Factory.create('PARTY_SELF', external_ref: double()) }
        it { is_expected.to be_an_instance_of Common::Generic::PartySelf }
      end

      describe PartyRelatedFactory do
        subject { Factory.create('PARTY_RELATED', name: 'related', relationship: double()) }
        it { is_expected.to be_an_instance_of Common::Generic::PartyRelated }
      end

      describe ParticipationFactory do
        subject {
          Factory.create('PARTICIPATION', performer: double(), function: double(), mode: double())
        }
        it { is_expected.to be_an_instance_of Common::Generic::Participation }
      end

      describe LinkFactory do
        subject { Factory.create('LINK', meaning: double(), target: double(), type: double()) }
        it { is_expected.to be_an_instance_of Common::Archetyped::Link }
      end

      describe FeederAuditFactory do
        subject { Factory.create('FEEDER_AUDIT', originating_system_audit: double()) }
        it { is_expected.to be_an_instance_of Common::Archetyped::FeederAudit }
      end

      describe AuditDetailsFactory do
        subject {
          Factory.create('AUDIT_DETAILS', system_id: 'sys', committer: double(),
                         time_committed: double(), change_type: double(), description: double())
        }
        it { is_expected.to be_an_instance_of Common::Generic::AuditDetails }
      end

      describe AttestationFactory do
        subject {
          Factory.create('ATTESTATION', system_id: 'sys', committer: double(),
                         time_committed: double(), change_type: double(),
                         reason: 'reason', proof: 'proof', is_pending: false)
        }
        it { is_expected.to be_an_instance_of Common::Generic::Attestation }
      end

      describe ObjectRefFactory do
        subject { Factory.create('OBJECT_REF', namespace: 'local', type: 'PARTY', id: double()) }
        it { is_expected.to be_an_instance_of Support::Identification::ObjectRef }
      end

      describe LocatableRefFactory do
        subject { Factory.create('LOCATABLE_REF', namespace: 'local', type: 'COMPOSITION', id: double()) }
        it { is_expected.to be_an_instance_of Support::Identification::LocatableRef }
      end

      describe ObjectVersionIdFactory do
        subject { Factory.create('OBJECT_VERSION_ID', value: 'F7C5C7B7-75DB-4b39-9A1E-C0BA9BFDBDEC::sys::2') }
        it { is_expected.to be_an_instance_of Support::Identification::ObjectVersionID }
      end

      describe HierObjectIdFactory do
        subject { Factory.create('HIER_OBJECT_ID', value: 'ehr::localhost/3030') }
        it { is_expected.to be_an_instance_of Support::Identification::HierObjectID }
      end

      describe UidBasedIdFactory do
        subject { Factory.create('UID_BASED_ID', value: 'ehr::localhost/3030') }
        it { is_expected.to be_an_instance_of Support::Identification::UIDBasedID }
      end

      describe AccessGroupRefFactory do
        subject { Factory.create('ACCESS_GROUP_REF', namespace: 'local', type: 'ACCESS_GROUP', id: double()) }
        it { is_expected.to be_an_instance_of Support::Identification::AccessGroupRef }
      end

      describe PersonFactory do
        subject {
          Factory.create('PERSON', archetype_node_id: 'at0001', name: Factory.create('DV_TEXT', value: 'person'),
                         uid: double(), identities: [double()])
        }
        it { is_expected.to be_an_instance_of Demographic::Person }
      end

      describe OrganisationFactory do
        subject {
          Factory.create('ORGANISATION', archetype_node_id: 'at0001', name: Factory.create('DV_TEXT', value: 'org'),
                         uid: double(), identities: [double()])
        }
        it { is_expected.to be_an_instance_of Demographic::Organisation }
      end

      describe RoleFactory do
        subject {
          Factory.create('ROLE', archetype_node_id: 'at0001', name: Factory.create('DV_TEXT', value: 'role'),
                         uid: double(), identities: [double()], performer: double())
        }
        it { is_expected.to be_an_instance_of Demographic::Role }
      end

      describe PartyIdentityFactory do
        subject {
          Factory.create('PARTY_IDENTITY', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'name'), details: double())
        }
        it { is_expected.to be_an_instance_of Demographic::PartyIdentity }
      end

      describe ContactFactory do
        subject {
          Factory.create('CONTACT', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'contact'), addresses: [double()])
        }
        it { is_expected.to be_an_instance_of Demographic::Contact }
      end

      describe AddressFactory do
        subject {
          Factory.create('ADDRESS', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'address'), details: double())
        }
        it { is_expected.to be_an_instance_of Demographic::Address }
      end

      describe CapabilityFactory do
        subject {
          Factory.create('CAPABILITY', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'capability'), credentials: double())
        }
        it { is_expected.to be_an_instance_of Demographic::Capability }
      end

      describe PartyRelationshipFactory do
        subject {
          Factory.create('PARTY_RELATIONSHIP', archetype_node_id: 'at0001',
                         name: Factory.create('DV_TEXT', value: 'relationship'),
                         uid: double(), source: double(), target: double())
        }
        it { is_expected.to be_an_instance_of Demographic::PartyRelationship }
      end

      describe CompositionFactory do
        let(:composition) { CompositionFactory.create_from_json(COMPOSITION_JSON)}
        subject { composition }

        it { is_expected.to be_an_instance_of ::OpenEHR::RM::Composition::Composition }
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
            "code_string": "433"
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
                "namespace": "local",
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
