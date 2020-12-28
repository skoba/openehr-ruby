require 'active_support/inflector'

module OpenEHR
  module RM
    class Factory
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
            if value.instance_of? Hash
              parameters[key] = Factory.create(value[:_type], **value)
            else
              parameters[key] = value
            end
          end
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

    class TermMappingFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Text::TermMapping.new(*param)
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


