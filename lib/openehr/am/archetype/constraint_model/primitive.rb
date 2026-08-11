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

            def valid_value?(value)
              (value == true && true_valid?) || (value == false && false_valid?)
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
            attr_accessor :list_open

            def initialize(args = { })
              args[:type] = 'String'
              super
              consistency(args[:pattern], args[:list])
              @pattern = args[:pattern]
              @list = args[:list]
              @list_open = args[:list_open]
            end

            def pattern=(pattern)
              consistency(pattern, @list)
              @pattern = pattern
            end

            def list=(list)
              consistency(@pattern, list)
              @list = list
            end

            def valid_value?(value)
              return false unless value.is_a?(String)
              return true if pattern.nil? && list.nil?
              return list.include?(value) if list

              Regexp.new(pattern).match?(value)
            end

            private
            # C_STRING may be fully unconstrained (neither pattern nor
            # list, i.e. any_allowed); only having both set
            # simultaneously is a genuine contradiction.
            def consistency(pattern, list)
              if !pattern.nil? && !list.nil?
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

            def valid_value?(value)
              return false unless value.is_a?(Integer)

              constrained_value?(value)
            end

            private
            # C_INTEGER may be fully unconstrained (neither list nor range,
            # i.e. any_allowed); only having both set simultaneously is a
            # genuine contradiction.
            def consistency(list, range)
              if !list.nil? && !range.nil?
                raise ArgumentError, 'consistency invalid'
              end
            end

            def constrained_value?(value)
              return true if list.nil? && range.nil?
              return list.include?(value) if list

              range.has?(value)
            end
          end

          class CReal < CInteger
            def initialize(args = { })
              args[:type] = 'Real'
              super
            end

            def valid_value?(value)
              return false unless value.is_a?(Numeric)

              constrained_value?(value)
            end
          end

          module CDateModule
            attr_accessor :timezone_validity, :day_validity, :range, :list
            attr_reader :month_validity, :pattern

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

            def valid_value?(value)
              date = as_date(value)
              return false if date.nil?

              date_fields_valid?(date) && constrained_date?(date)
            end

            protected
            def valid_pattern?(pattern)
              if /^([Yy?X]{4})(-([Mm?X]{2})(-([Dd?X]{2}))?)?$/ =~ pattern
                true
              else
                false
              end
            end

            def date_fields_valid?(date)
              validity_satisfied?(month_validity, !date.month_unknown?) &&
                validity_satisfied?(day_validity, !date.day_unknown?)
            end

            def validity_satisfied?(validity, field_present)
              case validity
              when ValidityKind::DISALLOWED then !field_present
              when ValidityKind::MANDATORY then field_present
              else
                true
              end
            end

            private
            def consistency_validity(month_validity, day_validity)
            end

            # A String value is parsed as a DV_DATE (matching the
            # concrete type this codebase's range/list bounds actually
            # use, so Comparable/Interval#has? compare like with like);
            # a malformed string surfaces as ArgumentError, caught below.
            def as_date(value)
              return value if value.respond_to?(:month_unknown?)
              return nil unless value.is_a?(String)

              OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate.new(:value => value)
            rescue ArgumentError
              nil
            end

            def constrained_date?(date)
              return true if range.nil? && list.nil?
              return list.any? { |item| as_date(item) == date } if list

              range.has?(date)
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
            attr_accessor :range, :list, :timezone_validity
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

            def valid_value?(value)
              time = as_time(value)
              return false if time.nil?

              time_fields_valid?(time) && constrained_time?(time)
            end

            protected
            def valid_pattern?(pattern)
              if /^([Hh?X]{2})(:([Mm?X]{2})(:([Ss?X]{2}))?)?$/ =~ pattern
                true
              else
                false
              end
            end

            def time_fields_valid?(time)
              validity_satisfied?(minute_validity, !time.minute_unknown?) &&
                validity_satisfied?(second_validity, !time.second_unknown?) &&
                validity_satisfied?(millisecond_validity, time.has_fractional_second?)
            end

            def validity_satisfied?(validity, field_present)
              case validity
              when ValidityKind::DISALLOWED then !field_present
              when ValidityKind::MANDATORY then field_present
              else
                true
              end
            end

            private

            # A String value is parsed as a DV_TIME (matching the
            # concrete type this codebase's range/list bounds actually
            # use, so Comparable/Interval#has? compare like with like);
            # a malformed string surfaces as ArgumentError, caught below.
            def as_time(value)
              return value if value.respond_to?(:minute_unknown?)
              return nil unless value.is_a?(String)

              OpenEHR::RM::DataTypes::Quantity::DateTime::DvTime.new(:value => value)
            rescue ArgumentError
              nil
            end

            def constrained_time?(time)
              return true if range.nil? && list.nil?
              return list.any? { |item| as_time(item) == time } if list

              range.has?(time)
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
              self.hour_validity = args[:hour_validity]
              self.day_validity = args[:day_validity]
              self.month_validity = args[:month_validity]
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

            def valid_value?(value)
              datetime = as_datetime(value)
              return false if datetime.nil?

              date_fields_valid?(datetime) && time_fields_valid?(datetime) &&
                validity_satisfied?(hour_validity, !datetime.hour_unknown?) &&
                constrained_datetime?(datetime)
            end

            protected
            def valid_pattern?(pattern)
              if /^([Yy?X]{4})(-([Mm?X]{2})(-([Dd?X]{2}))?)?[T ]?([Hh?X]{2})(:([Mm?X]{2})(:([Ss?X]{2}))?)?$/ =~ pattern
                true
              else
                false
              end
            end

            private

            # A String value is parsed as a DV_DATE_TIME (matching the
            # concrete type this codebase's range/list bounds actually
            # use, so Comparable/Interval#has? compare like with like);
            # a malformed string surfaces as ArgumentError, caught below.
            def as_datetime(value)
              return value if value.respond_to?(:hour_unknown?)
              return nil unless value.is_a?(String)

              OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime.new(:value => value)
            rescue ArgumentError
              nil
            end

            def constrained_datetime?(datetime)
              return true if range.nil? && list.nil?
              return list.any? { |item| as_datetime(item) == datetime } if list

              range.has?(datetime)
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
              self.years_allowed = args[:years_allowed]
              self.months_allowed = args[:months_allowed]
              self.weeks_allowed = args[:weeks_allowed]
              self.days_allowed = args[:days_allowed]
              self.hours_allowed = args[:hours_allowed]
              self.minutes_allowed = args[:minutes_allowed]
              self.seconds_allowed = args[:seconds_allowed]
              self.fractional_seconds_allowed = args[:fractional_seconds_allowed]
            end

            def valid_value?(value)
              duration = as_duration(value)
              return false if duration.nil?
              return false unless fields_allowed?(duration)
              return true if list.nil? && range.nil?
              return list.any? { |item| as_duration(item).to_seconds == duration.to_seconds } if list

              range.has?(duration)
            end

            private

            # A String value is parsed as a DV_DURATION (matching the
            # concrete type this codebase's range/list bounds actually
            # use, so Comparable/Interval#has? compare like with like);
            # a malformed string surfaces as ArgumentError, caught below.
            def as_duration(value)
              return value if value.respond_to?(:to_seconds)
              return nil unless value.is_a?(String)

              OpenEHR::RM::DataTypes::Quantity::DateTime::DvDuration.new(:value => value)
            rescue ArgumentError
              nil
            end

            def fields_allowed?(duration)
              [[years_allowed, duration.years], [months_allowed, duration.months],
               [weeks_allowed, duration.weeks], [days_allowed, duration.days],
               [hours_allowed, duration.hours], [minutes_allowed, duration.minutes],
               [seconds_allowed, duration.seconds],
               [fractional_seconds_allowed, duration.fractional_second]].all? do |allowed, field|
                allowed != false || field.nil?
              end
            end
          end
        end # of Primitive
      end # of CostraintModel
    end # of Archetype
  end # of AM
end # of OpenEHR
