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

    class DvTextFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Text::DvText.new(*param)
      end
    end

    class DvCodedTextFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Text::DvCodedText.new(*param)
      end
    end
    class DvQuantityFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Quantity::DvQuantity.new(*param)
      end
    end
  end
end
