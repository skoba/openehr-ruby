require 'active_support/inflector'

module OpenEHR
  module RM

    class Factory
      include ::OpenEHR::RM::DataTypes::Text
      include ::OpenEHR::RM::DataTypes::Quantity

      def self.create(type, *param)
        type = type.downcase.camelize if type.include? '_'
        class_eval("#{type}").new(*param)
      end
    end

    # class DvTextFactory
    #   def self.create(*param)
    #     OpenEHR::RM::DataTypes::Text::DvText.new(*param)
    #   end
    # end

    # class DvQuantityFactory
    #   def self.create(*param)
    #     OpenEHR::RM::DataTypes::Quantity::DvQuantity.new(*param)
    #   end
    # end
  end
end
