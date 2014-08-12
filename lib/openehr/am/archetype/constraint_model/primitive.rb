# Ticket #71
module OpenEHR
  module AM
    module Archetype
      module ConstraintModel
        module Primitive
          class CPrimitive
            attr_reader :type
            attr_accessor :assumed_value, :default_value

            def initialize(args = { })
              self.default_value = args[:default_value]
              self.assumed_value = args[:assumed_value]
              self.type = args[:type]
              @type ||= 'ANY'
            end

            def type=(type)
              if !type.nil? && type.empty?
                raise ArgumentError, 'type should not be empty'
              end
              @type = type
            end

            def has_assumed_value?
              return !assumed_value.nil?
            end
          end

          class CBoolean < CPrimitive
            attr_reader :true_valid, :false_valid

            def initialize(args = { })
              binary_consistency(args[:true_valid], args[:false_valid])
              @true_valid = args[:true_valid]
              @false_valid = args[:false_valid]
              args[:type] = 'Boolean'
              super(args)
            end

            def default_value=(default_value)
              super
              default_value_consistency(default_value) unless default_value.nil?
            end

            def true_valid=(true_valid)
              binary_consistency(true_valid, @false_valid)
              @true_valid = true_valid
            end

            def false_valid=(false_valid)
              binary_consistency(@true_valid, false_valid)
              @false_valid = false_valid
            end

            def true_valid?
              return @true_valid
            end

            def false_valid?
              return @false_valid
            end

            private
            def binary_consistency(true_valid, false_valid)
              if (true_valid == false) && (false_valid == false)
                raise ArgumentError, 'true_valid or false_valid should be true'
              end
            end

            def default_value_consistency(default_value)
              if (!@true_valid && default_value) || ((!@false_valid) && (!default_value))
                raise ArgumentError, 'default value inconsistency'
              end
            end
          end

          class CString < CPrimitive
            attr_reader :pattern, :list

            def initialize(args = { })
              args[:type] = 'String'
              super
              consistency(args[:pattern], args[:list])
              @pattern = args[:pattern]
              @list = args[:list]
            end

            def pattern=(pattern)
              consistency(pattern, @list)
              @pattern = pattern
            end

            def list=(list)
              consistency(@pattern, list)
              @list = list
            end

            private
            def consistency(pattern, list)
              if pattern.nil? == list.nil?
                raise ArgumentError, 'consistency invaild'
              end
            end
          end

          class CInteger < CPrimitive
            attr_reader :list, :range

            def initialize(args = { })
              args[:type] ||= 'Integer'
              super
              consistency(args[:list], args[:range])
              @list = args[:list]
              @range = args[:range]
            end

            def list=(list)
              consistency(list, @range)
              @list = list
            end

            def range=(range)
              consistency(@list, range)
              @range = range
            end

            private
            def consistency(list, range)
              if list.nil? == range.nil?
                raise ArgumentError, 'consistency invalid'
              end
            end
          end

          class CReal < CInteger
            def initialize(args = { })
              args[:type] = 'Real'
              super
            end
          end

          module CDateModule
            attr_accessor :timezone_validity, :day_validity, :range, :list
            attr_reader :month_validity, :day_validity, :range, :pattern

            def month_validity=(month_validity)
              if (month_validity == ValidityKind::OPTIONAL &&
                  !(@day_validity == ValidityKind::OPTIONAL ||
                    @day_validity == ValidityKind::DISALLOWED)) ||
                  (month_validity == ValidityKind::DISALLOWED &&
                  !(@day_validity == ValidityKind::DISALLOWED))
                raise ArgumentError, 'month validity disallowed'
              end
              @month_validity = month_validity
            end

            def pattern=(pattern)
              @pattern = pattern if valid_pattern?(pattern)
            end

            def validity_is_range?
              return !@range.nil?
            end

            protected
            def valid_pattern?(pattern)
              if /^([Yy?X]{4})(-([Mm?X]{2})(-([Dd?X]{2}))?)?$/ =~ pattern
                true
              else
                false
              end
            end

            private
            def consistency_validity(month_validity, day_validity)
            end
          end

          class CDate < CPrimitive
            include CDateModule

            def initialize(args = { })
              args[:type] = 'ISO8601_DATE'
              super
              @range = args[:range]
              if args[:pattern]
                self.pattern = args[:pattern]
              end
              self.list = args[:list]
              self.timezone_validity = args[:timezone_validity]
              self.day_validity = args[:day_validity]
              self.month_validity = args[:month_validity]
            end

            def range=(range)
              consistency(@pattern, range)
              @range = range
            end

            def pattern=(pattern)
              consistency(pattern, @range)
              @pattern = pattern
            end

            protected
            def consistency(pattern, range)
              if pattern.nil? == range.nil?
                raise ArgumentError, 'consistency invaild'
              end
            end
          end

          module CTimeModule
            attr_accessor :range, :list
            attr_reader :minute_validity, :second_validity,
                        :millisecond_validity, :pattern
            def pattern=(pattern)
              @pattern = pattern if valid_pattern? pattern
            end

            def minute_validity=(minute_validity)
              if (minute_validity == ValidityKind::OPTIONAL &&
                  @second_validity == ValidityKind::MANDATORY) ||
                  (minute_validity == ValidityKind::DISALLOWED &&
                   @second_validity != ValidityKind::DISALLOWED)
                raise ArgumentError, 'minute_validity is invalid'
              end
              @minute_validity = minute_validity
            end

            def second_validity=(second_validity)
              if (second_validity == ValidityKind::OPTIONAL &&
                  @millisecond_validity == ValidityKind::MANDATORY) ||
                  (second_validity == ValidityKind::DISALLOWED &&
                   @millisecond_validity != ValidityKind::DISALLOWED)
                raise ArgumentError, 'second_validity is invalid'
              end
              @second_validity = second_validity
            end

            def millisecond_validity=(millisecond_validity)
              @millisecond_validity = millisecond_validity
            end

            def validity_is_range?
              return !@range.nil?
            end

            protected
            def valid_pattern?(pattern)
              if /^([Hh?X]{2})(:([Mm?X]{2})(:([Ss?X]{2}))?)?$/ =~ pattern
                true
              else
                false
              end
            end
          end

          class CTime < CPrimitive
            include CTimeModule

            def initialize(args = { })
              args[:type] = 'ISO8601_TIME'
              super
              self.pattern = args[:pattern]
              self.range = args[:range]
              self.list = args[:list]
              self.millisecond_validity = args[:millisecond_validity]
              self.second_validity = args[:second_validity]
              self.minute_validity = args[:minute_validity]
            end
          end

          class CDateTime < CPrimitive
            include CDateModule, CTimeModule
            attr_reader :hour_validity

            def initialize(args = { })
              args[:type] = 'ISO8601_DATE_TIME'
              super
              self.pattern = args[:pattern]
              self.list = args[:list]
              self.range = args[:range]
              self.timezone_validity = args[:timezone_validity]
              self.millisecond_validity = args[:millisecond_validity]
              self.second_validity = args[:second_validity]
              self.minute_validity = args[:minute_validity]
              self.hour_validity = args[:hour_vaildity]
              self.day_validity = args[:day_validity]
              self.month_validity = args[:day_validity]
            end

            def hour_validity=(hour_validity)
              if (hour_validity == ValidityKind::DISALLOWED &&
                  @minute_validity != ValidityKind::DISALLOWED) ||
                  (hour_validity == ValidityKind::OPTIONAL &&
                   !(@minute_validity == ValidityKind::OPTIONAL ||
                     @minute_validity == ValidityKind::DISALLOWED))
                raise ArgumentError, 'hour_validity is invalid'
              end
              @hour_validity = hour_validity
            end

            def day_validity=(day_validity)
              if (day_validity == ValidityKind::DISALLOWED &&
                  @hour_validity != ValidityKind::DISALLOWED) ||
                  (day_validity == ValidityKind::OPTIONAL &&
                   !(@hour_validity == ValidityKind::OPTIONAL ||
                     @hour_validity == ValidityKind::DISALLOWED))
                raise ArgumentError, 'day_validity is invaild'
              end
              @day_validity = day_validity
            end

            protected
            def valid_pattern?(pattern)
              if /^([Yy?X]{4})(-([Mm?X]{2})(-([Dd?X]{2}))?)?[T ]?([Hh?X]{2})(:([Mm?X]{2})(:([Ss?X]{2}))?)?$/ =~ pattern
                true
              else
                false
              end
            end
          end

          class CDuration < CPrimitive
            attr_accessor :years_allowed, :months_allowed, :weeks_allowed
            attr_accessor :days_allowed, :hours_allowed, :minutes_allowed
            attr_accessor :seconds_allowed, :fractional_seconds_allowed
            attr_accessor :pattern, :list, :range

            def initialize(args = { })
              args[:type] = 'ISO8601_DURATION'
              super
              self.pattern = args[:pattern]
              self.list = args[:list]
              self.range = args[:range]
            end
          end
        end # of Primitive
      end # of CostraintModel
    end # of Archetype
  end # of AM
end # of OpenEHR
