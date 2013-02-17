module OpenEHR
  module RM
    class Factory
      def self.create(type, *param)
        class_eval("#{type}Factory").create(*param)
      end
    end

    class DvTextFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Text::DvText.new(*param)
      end
    end

    class DvQuantityFactory
      def self.create(*param)
        OpenEHR::RM::DataTypes::Quantity::DvQuantity.new(*param)
      end
    end
  end
end
