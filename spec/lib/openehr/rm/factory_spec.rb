# coding: utf-8
require_relative  File.dirname(__FILE__) + '/../../../spec_helper'
require_relative File.dirname(__FILE__) + '/../adl_parser/parser_spec_helper'
module OpenEHR
  module RM
    describe Factory do
      describe '.params' do
        it 'converts each Hash element of an Array value into an RM object via its _type' do
          result = Factory.params(
            items: [
              { _type: 'DV_TEXT', value: 'first' },
              { _type: 'DV_TEXT', value: 'second' }
            ]
          )
          expect(result[:items]).to all(be_an_instance_of(OpenEHR::RM::DataTypes::Text::DvText))
          expect(result[:items].map(&:value)).to eq(%w[first second])
        end

        it 'passes an empty Array value through as an empty Array' do
          expect(Factory.params(items: [])[:items]).to eq([])
        end

        it 'passes Array elements that are not Hashes through unchanged (e.g. DV_PARAGRAPH item strings)' do
          result = Factory.params(items: ['short sentence', 'long sentence'])
          expect(result[:items]).to eq(['short sentence', 'long sentence'])
        end

        it 'converts Hash elements inside nested Arrays recursively' do
          result = Factory.params(rows: [[{ _type: 'DV_TEXT', value: 'cell' }]])
          expect(result[:rows].first.first).to be_an_instance_of(OpenEHR::RM::DataTypes::Text::DvText)
        end
      end

      describe HistoryFactory do
        subject do
          Factory.create('HISTORY',
                          archetype_node_id: 'at0001',
                          name: Factory.create('DV_TEXT', value: 'Event Series'),
                          origin: Factory.create('DV_DATE_TIME', value: '2020-09-22T16:18:51+02:00'),
                          events: [{ _type: 'POINT_EVENT',
                                     archetype_node_id: 'at0002',
                                     name: { _type: 'DV_TEXT', value: 'Any event' },
                                     time: { _type: 'DV_DATE_TIME', value: '2020-09-22T16:18:51+02:00' },
                                     data: { _type: 'ITEM_TREE',
                                             archetype_node_id: 'at0003',
                                             name: { _type: 'DV_TEXT', value: 'Tree' } } }])
        end

        it 'builds real PointEvent objects from an events array of typed Hashes' do
          expect(subject.events.first).to be_an_instance_of(OpenEHR::RM::DataStructures::History::PointEvent)
        end

        it 'wires the parent back-reference on each built event' do
          expect(subject.events.first.parent).to equal(subject)
        end
      end

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

      describe DvScaleFactory do
        subject { Factory.create('DV_SCALE', value: 0.5, symbol: double()) }

        it { is_expected.to be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvScale }
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

        it 'builds real Observation objects in content, not raw Hashes' do
          expect(composition.content).to all(
            be_an_instance_of(OpenEHR::RM::Composition::Content::Entry::Observation)
          )
          expect(composition.content.first.archetype_node_id).to eq('openEHR-EHR-OBSERVATION.story.v1')
        end

        it 'makes every node in content Pathable (the AQL CONTAINS prerequisite)' do
          expect(composition.content.first).to be_a(OpenEHR::RM::Common::Archetyped::Pathable)
        end

        it 'builds real Participation objects in context.participations' do
          expect(composition.context.participations).to all(
            be_an_instance_of(OpenEHR::RM::Common::Generic::Participation)
          )
        end

        it 'recurses through content -> data.events -> ITEM_TREE -> CLUSTER -> ELEMENT' do
          observation = composition.content.first
          event = observation.data.events.first
          expect(event).to be_an_instance_of(OpenEHR::RM::DataStructures::History::PointEvent)

          cluster = event.data.items.last
          expect(cluster).to be_an_instance_of(OpenEHR::RM::DataStructures::ItemStructure::Representation::Cluster)
          expect(cluster.archetype_node_id).to eq('openEHR-EHR-CLUSTER.symptom_sign.v1')

          element = cluster.items.first
          expect(element).to be_an_instance_of(OpenEHR::RM::DataStructures::ItemStructure::Representation::Element)
          expect(element.value.value).to eq('咳、鼻水')
        end

        it 'wires the parent back-reference on a content element' do
          expect(composition.content.first.parent).to equal(composition)
        end
      end
    end
  end
end

COMPOSITION_JSON = File.read(File.expand_path('../../../fixtures/health_summary_composition.json', __dir__))
