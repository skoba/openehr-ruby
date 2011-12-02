$:.unshift(File.dirname(__FILE__))
# This modules are implemented from the UML shown bellow
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109599337877_94556_1510Report.html
# Ticket refs #50

require 'assumed_library_types'

module OpenEHR
  module RM
    module DataTypes
      module Quantity
        autoload :DateTime, 'quantity/date_time'

        class DvOrdered < OpenEHR::RM::DataTypes::Basic::DataValue
          include Comparable
          attr_accessor :normal_range, :other_refference_ranges, :normal_status

          def initialize(args = {})
            super(args)
            self.normal_range = args[:normal_range]
            self.normal_status = args[:normal_status]
            self.other_reference_ranges = args[:other_reference_ranges]
          end          

          def is_normal?
            if @normal_range.nil? and @normal_status.nil?
              return false
            elsif !@normal_range.nil?
              return @normal_range.has(@value)
            elsif !@normal_status.nil?
              return @normal_status.code_string == 'N'
            end
          end

          def is_simple?
            return @other_reference_ranges.nil?
          end

          def <=>(other)
            raise NotImplementedError, 'This method should be implemented'
          end

          def other_reference_ranges=(other_reference_ranges)
            if !other_reference_ranges.nil? && other_reference_ranges.empty?
              raise ArgumentError, "Other reference ranges validity error"
            end
            @other_reference_ranges = other_reference_ranges
          end

          def is_strictly_comparable_to?(others)
            if others.instance_of? self.class
              return true
            else
              return false
            end
          end
        end

        class DvInterval < OpenEHR::AssumedLibraryTypes::Interval

        end

        class DvQuantified < DvOrdered
          attr_reader :magnitude, :magnitude_status

          def initialize(args = {})
            super(args)
            self.magnitude = args[:magnitude]
            self.magnitude_status = args[:magnitude_status]
          end

          def <=>(others)
            self.magnitude <=> others.magnitude
          end

          def magnitude=(magnitude)
            raise ArgumentError, 'magnitude should not be nil' if magnitude.nil?
            @magnitude = magnitude
          end

          def magnitude_status=(magnitude_status)
            if magnitude_status.nil?
              @magnitude_status = '='
            elsif DvQuantified.valid_magnitude_status?(magnitude_status)
              @magnitude_status = magnitude_status
            else
              raise ArgumentError, 'magnitude_status invalid'
            end
          end

          def accuracy_unknown?
            return @accuracy.nil?
          end

          def self.valid_magnitude_status?(s)
            if s == '=' || s == '>' || s == '<' || s == '<=' ||
                s == '>=' || s == '~'
              return true
            else
              return false
            end
          end
        end

        class DvOrdinal < DvOrdered
          attr_reader :value, :symbol, :limits

          def initialize(args = {})
            super(args)
            self.symbol = args[:symbol]
            self.limits = args[:limits]
          end

          def value=(value)
            raise ArgumentError, 'value should not be nil' if value.nil?
            @value = value
          end

          def symbol=(symbol)
            raise ArgumentError,'symbol should not be nil' if symbol.nil?
            @symbol = symbol
          end

          def <=>(other)
            @value <=> other.value
          end

          def limits=(limits)
            unless limits.nil? or limits.meaning.value == 'limits'
              raise ArgumentError, 'invalid limits'
            else
              @limits = limits
            end
          end
          def is_strictly_comparable_to?(others)
            unless super(others)
              return false
            end
            unless others.symbol.defining_code.terminology_id.value ==
                @symbol.defining_code.terminology_id.value
              return false
            else
              return true
            end
          end
        end

        class DvAbsoluteQuantity < DvQuantified
          attr_accessor :accuracy

          def initialize(args = {})
            super(args)
            self.accuracy = args[:accuracy]
          end

          def add(a_diff)
            type_check(a_diff)
            return result_builder(self.class,
                                  @magnitude+a_diff.magnitude)
          end

          def diff(other)
            type_check(other)
            return result_builder(self.class,
                                  (@magnitude-other.magnitude).abs)
          end

          def subtract(a_diff)
            type_check(a_diff)
            return result_builder(self.class,
                                  @magnitude-a_diff.magnitude)
          end
          private
          def type_check(other)
            unless self.is_strictly_comparable_to? other
              raise ArgumentError, 'type mismatch'
            end
          end

          def result_builder(klass, magnitude)
            return klass.new(:magnitude => magnitude,
                             :magnitude_status => @magnitude_status,
                             :accuracy => @accuracy,
                             :accuracy_percent => @accuracy_percent,
                             :normal_range => @normal_range,
                             :normal_status => @normal_status,
                             :other_reference_ranges => @other_reference_ranges)
          end
        end

        class DvAmount < DvQuantified
          attr_reader :accuracy, :accuracy_percent

          def initialize(args = {})
            super(args)
            unless args[:accuracy].nil?
              set_accuracy(args[:accuracy], args[:accuracy_percent])
            else
              @accuracy, @accuracy_percent = nil, nil
            end
          end

          def +(other)
            unless self.is_strictly_comparable_to? other
              raise ArgumentError, 'type mismatch'
            end
            result = self.dup
            result.magnitude = @magnitude + other.magnitude
            return result
          end

          def -(other)            
            other.magnitude = - other.magnitude
            self+(other)
          end

          def set_accuracy(accuracy, accuracy_percent)
            if accuracy_percent
              raise ArgumentError, 'accuracy invalid' if accuracy < 0.0 || accuracy > 100.0
            else
              raise ArgumentError, 'accuracy invaild' if accuracy < 0.0 || accuracy > 1.0
            end
            @accuracy, @accuracy_percent = accuracy, accuracy_percent
          end

          def accuracy_is_percent?
            return @accuracy_percent
          end
        end

        class DvQuantity < DvAmount
          attr_reader :units, :precision

          def initialize(args = {})
            super(args)
            self.units = args[:units]
            self.precision = args[:precision]
          end

          def units=(units)
            raise ArgumentError, 'units should not be nil' if units.nil?
            @units = units
          end

          def precision=(precision)
            unless precision.nil? || precision >= -1
              raise ArgumentError, 'precision invalid'
            end
            @precision = precision
          end

          def is_strictly_comparable_to?(others)
            unless super(others)
              return false
            end
            if others.units == @units
              return true
            else
              return false
            end
          end

          def is_integral?
            if @precision.nil? || precision != 0
              return false
            else
              return true
            end
          end
        end

        class DvCount < DvAmount

        end

        class ReferenceRange
          attr_reader :meaning, :range

          def initialize(args = {})
            self.meaning = args[:meaning]
            self.range = args[:range]
          end

          def meaning=(meaning)
            if meaning.nil?
              raise ArgumentError, 'meaning should not be nil'
            end
            @meaning = meaning
          end

          def range=(range)
            if range.nil?
              raise ArgumentError, 'range should not be nil'
            end
            @range = range
          end

          def is_in_range?(val)
            return @range.has?(val)
          end
        end

        module ProportionKind
          PK_RATIO = 0
          PK_UNITARY = 1
          PK_PERCENT = 2
          PK_FRACTION = 3
          PK_INTEGER_FRACTION = 4

          def ProportionKind.valid_proportion_kind?(kind)
            return true if kind >= 0 && kind <= 4
            return false
          end
        end # end of ProportionKind

        class DvProportion < DvAmount
          include ProportionKind
          attr_reader :numerator, :denominator, :type, :precision

          def initialize(args = {})
            self.type = args[:type]
            self.numerator = args[:numerator]
            self.denominator = args[:denominator]
            self.precision = args[:precision]
            self.magnitude_status =args[:magnitude_status]
            unless args[:accuracy].nil?
              set_accuracy(args[:accuracy], args[:accuracy_percent])
            else
              @accuracy, @accuracy_percent = nil, nil
            end
            self.normal_range = args[:normal_range]
            self.normal_status = args[:normal_status]
            self.other_reference_ranges = args[:other_reference_ranges]
          end

          def numerator=(numerator)
            raise ArgumentError, 'numerator should not be nil' if numerator.nil?
            if (@type == PK_FRACTION || @type == PK_INTEGER_FRACTION) &&
                !numerator.integer?
              raise ArgumentError, 'numerator invalid for type'
            end
            @numerator = numerator
          end

          def denominator=(denominator)
            case @type
            when PK_UNITARY
              unless denominator == 1
                raise ArgumentError, 'Unitary denominator must be 1'
              end
            when PK_PERCENT
              unless denominator == 100
                raise ArgumentError, 'Percent denominator must be 100'
              end
            when PK_FRACTION, PK_INTEGER_FRACTION
              unless denominator.integer? and @numerator.integer?
                raise ArgumentError, 'Fraction numerator/denominator must be integer'
              end
            end
            @denominator = denominator
          end

          def type=(type)
            if ProportionKind.valid_proportion_kind?(type)
              @type = type
            else
              raise ArgumentError, 'type invalid'
            end
          end

          def magnitude
            return numerator.to_f/denominator.to_f
          end

          def precision=(precision)
            unless precision.nil?
              if (self.is_integral? && precision !=0)
                raise ArgumentError, 'precision invalid'
              end
            end
            @precision = precision
          end

          def is_integral?
            return denominator.integer? && numerator.integer?
          end

          def is_strictly_comparable_to?(other)
            unless super(other)
              return false
            end
            if other.type == @type
              return true
            else
              return false
            end
          end
        end # end of DvProportion
      end # of Quantity
    end # of Data_Types
  end # of RM
end # of OpenEHR
