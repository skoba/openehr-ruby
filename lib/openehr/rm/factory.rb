require 'active_support/inflector'

module OpenEHR
  module RM
    class Factory
      def self.create(type, *param)
        type = type.downcase.camelize if type.include? '_'
        class_eval("#{type}Factory").create(*param)
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
      def self.create(*param)
        OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate.new(*param)
      end
    end

    class DvTimeFactory
      def self.create(*param)
        DataTypes::Quantity::DateTime::DvTime.new(*param)
      end
    end

    class DvDateTimeFactory
      def self.create(*param)
        DataTypes::Quantity::DateTime::DvDateTime.new(*param)
      end
    end

    class DvDurationFactory
      def self.create(*param)
        DataTypes::Quantity::DateTime::DvDuration.new(*param)
      end
    end

    class DvEncapsulatedFactory
      def self.create(*param)
        DataTypes::Encapsulated::DvEncapsulated.new(*param)
      end
    end

    class DvMultimediaFactory
      def self.create(*param)
        DataTypes::Encapsulated::DvMultimedia.new(*param)
      end
    end

    class DvParsableFactory
      def self.create(*param)
        DataTypes::Encapsulated::DvParsable.new(*param)
      end
    end

    class DvUriFactory
      def self.create(*param)
        DataTypes::URI::DvUri.new(*param)
      end
    end

    class DvEhrUriFactory
      def self.create(*param)
        DataTypes::URI::DvEhrUri.new(*param)
      end
    end

    class OBSERVATIONFactory
      def self.create(*param)
        Composition::Content::Entry::Observation.new(*param)
      end
    end

    class SECTIONFactory
      def self.create(*param)
        Composition::Content::Navigation::Section.new(*param)
      end
    end
  end
end
