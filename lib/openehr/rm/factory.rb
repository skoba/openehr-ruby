require 'active_support/inflector'

module OpenEHR
  module RM
    class Factory
      # Attribute keys whose openEHR RM type is always exactly one
      # concrete class (never actually polymorphic), so a real-world
      # canonical-JSON serializer may legally omit _type for them - e.g.
      # openehr-rails's own CanonicalSerializer does. Consulted only as
      # a fallback when _type is absent; see convert_hash below.
      #
      # Deliberately does NOT include attributes whose declared type is
      # abstract (e.g. LOCATABLE.uid : UID_BASED_ID, which could be an
      # ObjectVersionID or a HierObjectID; OBJECT_REF.id : OBJECT_ID,
      # similarly abstract) - guessing there would silently build the
      # wrong object instead of failing loudly.
      NON_POLYMORPHIC_TYPE_FOR_KEY = {
        archetype_id: 'ARCHETYPE_ID',
        template_id: 'TEMPLATE_ID',
        terminology_id: 'TERMINOLOGY_ID'
      }.freeze

      def initialize(cobject)
        @cobject = cobject
      end

      class << self
        def create(type, **param)
          if type.include? '_'
            type = type.downcase.camelize
          else
            type = type.capitalize
          end
          class_eval("#{type}Factory").create(params(param))
        end

        def params(param)
          param.each_with_object({}) do |item, parameters|
            key = item.shift
            value = item.shift
            parameters[key] = convert_value(key, value)
          end
        end

        private

        # A canonical-JSON attribute value is either a typed sub-object
        # (Hash, normally with _type - see convert_hash for the
        # _type-less case), a List<...> of those (Array - openEHR RM
        # multiplicity 0..*/1..* attributes, e.g. COMPOSITION.content,
        # HISTORY.events, ITEM_TREE.items), or a plain value (String,
        # Numeric, ...). Arrays recurse (passing the same attribute key
        # down, since none of NON_POLYMORPHIC_TYPE_FOR_KEY's keys are
        # ever Array-valued) so nested multiplicities (e.g. a CLUSTER's
        # own items) convert too; non-Hash array elements (there is no
        # List<String>/List<Numeric> attribute in this RM, but doubles/
        # pre-built objects show up in specs) pass through unchanged.
        def convert_value(key, value)
          if value.instance_of? Hash
            convert_hash(key, value)
          elsif value.instance_of? Array
            value.map { |element| convert_value(key, element) }
          else
            value
          end
        end

        # _type is how a Hash normally says what RM class to become;
        # when it's absent, fall back to NON_POLYMORPHIC_TYPE_FOR_KEY.
        # Anything else raises with the attribute name rather than
        # silently guessing or passing a raw Hash through where an RM
        # object is expected (downstream code - e.g. Locatable#concept
        # calling archetype_id.concept_name - would then fail far from
        # the real cause).
        def convert_hash(key, value)
          type = value[:_type] || NON_POLYMORPHIC_TYPE_FOR_KEY[key]
          unless type
            raise ArgumentError,
                  "cannot determine the RM type for attribute #{key.inspect}: its Hash value has no _type key " \
                  "and #{key.inspect} is not a known non-polymorphic attribute (keys: #{value.keys.inspect})"
          end
          Factory.create(type, **value)
        end
      end

      def build
        Factory.create(type, params)
      end

      private
      def type
        @cobject.rm_type_name
      end

      def name
        OpenEHR::RM::DataTypes::Text::DvText.new(value: ' ')
      end

      def params
        @cobject.attributes.inject({}) do |hash, attribute|
          if attribute.children
            hash[attribute.rm_attribute_name.to_sym] =
              attribute.children.map { |child| Factory.new(child).build }
          end
          hash
        end.merge(
        { archetype_node_id: @cobject.node_id,
          occurrences: @cobject.occurrences })
      end
    end

    class DvBooleanFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Basic::DvBoolean.new(*param)
      end
    end

    class DvStateFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Basic::DvState.new(*param)
      end
    end

    class DvIdentifierFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Basic::DvIdentifier.new(*param)
      end
    end

    class DvTextFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Text::DvText.new(*param)
      end
    end

    class CodePhraseFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Text::CodePhrase.new(*param)
      end
    end

    class DvCodedTextFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Text::DvCodedText.new(*param)
      end
    end

    class DvParagraphFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Text::DvParagraph.new(*param)
      end
    end

    class DvOrderedFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Quantity::DvOrdered.new(*param)
      end
    end

    class DvIntervalFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Quantity::DvInterval.new(*param)
      end
    end

    class ReferenceRangeFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Quantity::ReferenceRange.new(*param)
      end
    end

    class DvOrdinalFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Quantity::DvOrdinal.new(*param)
      end
    end

    class DvScaleFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Quantity::DvScale.new(*param)
      end
    end

    class DvQuantifiedFactory
      def self.create(*param)
        DataTypes::Quantity::DvQuantified.new(*param)
      end
    end

    class DvAmountFactory
      def self.create(*param)
        DataTypes::Quantity::DvAmount.new(*param)
      end
    end

    class DvQuantityFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Quantity::DvQuantity.new(*param)
      end
    end

    class DvCountFactory
      def self.create(*param)
        DataTypes::Quantity::DvCount.new(*param)
      end
    end

    class DvProportionFactory
      def self.create(*param)
        DataTypes::Quantity::DvProportion.new(*param)
      end
    end

    class DvAbsoluteQuantityFactory
      def self.create(*param)
        DataTypes::Quantity::DvAbsoluteQuantity.new(*param)
      end
    end

    class DvTemporalFactory
      def self.create(*param)
        DataTypes::Quantity::DateTime::DvTemporal.new(*param)
      end
    end
    
    class DvDateFactory
      def self.create(param)
        OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate.new(param)
      end
    end

    class DvTimeFactory
      def self.create(param)
        DataTypes::Quantity::DateTime::DvTime.new(param)
      end
    end

    class DvDateTimeFactory
      def self.create(param)
        DataTypes::Quantity::DateTime::DvDateTime.new(param)
      end
    end

    class DvDurationFactory
      def self.create(param)
        DataTypes::Quantity::DateTime::DvDuration.new(param)
      end
    end

    class DvEncapsulatedFactory
      def self.create(param)
        DataTypes::Encapsulated::DvEncapsulated.new(param)
      end
    end

    class DvMultimediaFactory
      def self.create(param)
        DataTypes::Encapsulated::DvMultimedia.new(param)
      end
    end

    class DvParsableFactory
      def self.create(param)
        DataTypes::Encapsulated::DvParsable.new(param)
      end
    end

    class DvUriFactory
      def self.create(param)
        DataTypes::URI::DvUri.new(param)
      end
    end

    class DvEhrUriFactory
      def self.create(param)
        DataTypes::URI::DvEhrUri.new(param)
      end
    end

    class DvTimeSpecificationFactory
      def self.create(param)
        DataTypes::TimeSpecification::DvTimeSpecification.new(param)
      end
    end

    class DvGeneralTimeSpecificationFactory
      def self.create(param)
        DataTypes::TimeSpecification::DvGeneralTimeSpecification.new(param)
      end
    end

    class DvPeriodicTimeSpecificationFactory
      def self.create(param)
        DataTypes::TimeSpecification::DvPeriodicTimeSpecification.new(param)
      end
    end

    class ObservationFactory
      def self.create(param)
        Composition::Content::Entry::Observation.new(param)
      end
    end

    class SectionFactory
      def self.create(param)
        Composition::Content::Navigation::Section.new(param)
      end
    end

    class ClusterFactory
      def self.create(param)
        DataStructures::ItemStructure::Representation::Cluster.new(param)
      end
    end

    class ArchetypedFactory
      def self.create(param)
        OpenEHR::RM::Common::Archetyped::Archetyped.new(**param)
      end
    end

    class ArchetypeIdFactory
      def self.create(param)
        OpenEHR::RM::Support::Identification::ArchetypeID.new(param)
      end
    end

    class TemplateIdFactory
      def self.create(param)
        OpenEHR::RM::Support::Identification::TemplateID.new(param)
      end
    end

    class TerminologyIdFactory
      def self.create(param)
        OpenEHR::RM::Support::Identification::TerminologyID.new(param)
      end
    end

    class GenericIdFactory
      def self.create(param)
        OpenEHR::RM::Support::Identification::GenericID.new(param)
      end
    end

    class PartyRefFactory
      def self.create(param)
        OpenEHR::RM::Support::Identification::PartyRef.new(param)
      end
    end

    class PartyIdentifiedFactory
      def self.create(param)
        OpenEHR::RM::Common::Generic::PartyIdentified.new(param)
      end
    end

    class EventContextFactory
      def self.create(param)
        OpenEHR::RM::Composition::EventContext.new(param)
      end
    end

    class TermMappingFactory
      def self.create(param)
        OpenEHR::RM::DataTypes::Text::TermMapping.new(param)
      end
    end

    class ElementFactory
      def self.create(param)
        DataStructures::ItemStructure::Representation::Element.new(param)
      end
    end

    class ItemTreeFactory
      def self.create(param)
        DataStructures::ItemStructure::ItemTree.new(param)
      end
    end

    class ItemListFactory
      def self.create(param)
        DataStructures::ItemStructure::ItemList.new(param)
      end
    end

    class ItemSingleFactory
      def self.create(param)
        DataStructures::ItemStructure::ItemSingle.new(param)
      end
    end

    class ItemTableFactory
      def self.create(param)
        DataStructures::ItemStructure::ItemTable.new(param)
      end
    end

    class HistoryFactory
      def self.create(param)
        DataStructures::History::History.new(param)
      end
    end

    class EventFactory
      def self.create(param)
        DataStructures::History::Event.new(param)
      end
    end

    class PointEventFactory
      def self.create(param)
        DataStructures::History::PointEvent.new(param)
      end
    end

    class IntervalEventFactory
      def self.create(param)
        DataStructures::History::IntervalEvent.new(param)
      end
    end

    class EvaluationFactory
      def self.create(param)
        Composition::Content::Entry::Evaluation.new(param)
      end
    end

    class InstructionFactory
      def self.create(param)
        Composition::Content::Entry::Instruction.new(param)
      end
    end

    class ActionFactory
      def self.create(param)
        Composition::Content::Entry::Action.new(param)
      end
    end

    class ActivityFactory
      def self.create(param)
        Composition::Content::Entry::Activity.new(param)
      end
    end

    class AdminEntryFactory
      def self.create(param)
        Composition::Content::Entry::AdminEntry.new(param)
      end
    end

    class InstructionDetailsFactory
      def self.create(param)
        Composition::Content::Entry::InstructionDetails.new(param)
      end
    end

    class IsmTransitionFactory
      def self.create(param)
        Composition::Content::Entry::IsmTransition.new(param)
      end
    end

    class GenericEntryFactory
      def self.create(param)
        Integration::GenericEntry.new(param)
      end
    end

    class PartySelfFactory
      def self.create(param)
        Common::Generic::PartySelf.new(param)
      end
    end

    class PartyRelatedFactory
      def self.create(param)
        Common::Generic::PartyRelated.new(param)
      end
    end

    class ParticipationFactory
      def self.create(param)
        Common::Generic::Participation.new(param)
      end
    end

    class LinkFactory
      def self.create(param)
        Common::Archetyped::Link.new(param)
      end
    end

    class FeederAuditFactory
      def self.create(param)
        Common::Archetyped::FeederAudit.new(param)
      end
    end

    class AuditDetailsFactory
      def self.create(param)
        Common::Generic::AuditDetails.new(param)
      end
    end

    class AttestationFactory
      def self.create(param)
        Common::Generic::Attestation.new(param)
      end
    end

    class ObjectRefFactory
      def self.create(param)
        Support::Identification::ObjectRef.new(param)
      end
    end

    class LocatableRefFactory
      def self.create(param)
        Support::Identification::LocatableRef.new(param)
      end
    end

    class ObjectVersionIdFactory
      def self.create(param)
        Support::Identification::ObjectVersionID.new(param)
      end
    end

    class HierObjectIdFactory
      def self.create(param)
        Support::Identification::HierObjectID.new(param)
      end
    end

    class UidBasedIdFactory
      def self.create(param)
        Support::Identification::UIDBasedID.new(param)
      end
    end

    class AccessGroupRefFactory
      def self.create(param)
        Support::Identification::AccessGroupRef.new(param)
      end
    end

    class PersonFactory
      def self.create(param)
        Demographic::Person.new(param)
      end
    end

    class OrganisationFactory
      def self.create(param)
        Demographic::Organisation.new(param)
      end
    end

    class RoleFactory
      def self.create(param)
        Demographic::Role.new(param)
      end
    end

    class PartyIdentityFactory
      def self.create(param)
        Demographic::PartyIdentity.new(param)
      end
    end

    class ContactFactory
      def self.create(param)
        Demographic::Contact.new(param)
      end
    end

    class AddressFactory
      def self.create(param)
        Demographic::Address.new(param)
      end
    end

    class CapabilityFactory
      def self.create(param)
        Demographic::Capability.new(param)
      end
    end

    class PartyRelationshipFactory
      def self.create(param)
        Demographic::PartyRelationship.new(param)
      end
    end

    class CompositionFactory < Factory
      class << self
        def create_from_json(json)
          hash = JSON.parse(json, max_nesting: false, symbolize_names: true)
          OpenEHR::RM::Composition::Composition.new(params(hash))
        end
      end
    end
  end
end


