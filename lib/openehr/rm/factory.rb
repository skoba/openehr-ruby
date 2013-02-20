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

    class DvQuantityFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Quantity::DvQuantity.new(*param)
      end
    end

    class DvDateFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate.new(*param)
      end
    end
  end
end
