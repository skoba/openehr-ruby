module OpenEHR
  module Parser
    module CADL
      class ArchetypeNode
        attr_reader :parent
        attr_accessor :path, :id

        def initialize(parent = nil)
          @parent = parent
          @path = '/' if parent.nil?
        end

        def root?
          return parent.nil?
        end
      end

      class CDvQuantityItems < Treetop::Runtime::SyntaxNode
        def value(node)
          property = prop.value unless prop.empty?
          list = ql.value(node) unless ql.empty?
          av = aqv.value unless aqv.empty?
          OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvQuantity.new(
            :path => node.path, :rm_type_name => 'DvQuantity',
            :occurrences => OpenEHR::AssumedLibraryTypes::Interval.new(
              :upper => 1, :lower => 1),
            :property => property, :list => list, :assumed_value => av)
        end
      end

      class AssumedValueItems < Treetop::Runtime::SyntaxNode
        def value
          magnitude, precision = nil
          magnitude = mag.val.value unless mag.empty?
          precision = prec.val.value unless prec.empty?
          OpenEHR::RM::DataTypes::Quantity::DvQuantity.new(
            :units => units.value,
            :magnitude => magnitude,
            :precision => precision)
        end
      end
    end
  end
end
