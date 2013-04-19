# This module is implementation of the UML:
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109696321450_28117_5362Report.html
# Ticket refs #49
require 'date'

require_relative '../../../assumed_library_types'
require_relative '../quantity'

module OpenEHR
  module RM
    module DataTypes
      module Quantity
        module DateTime

          class DvTemporal < OpenEHR::RM::DataTypes::Quantity::DvAbsoluteQuantity
            def initialize(args = {})
              self.value = args[:value]
              self.magnitude_status = args[:magnitude_status]
              self.accuracy = args[:accuracy]
              self.normal_range = args[:normal_range]
              self.normal_status = args[:normal_status]
              self.other_reference_ranges = args[:other_reference_ranges]
            end

            def value=(value)
              if value.nil? or value.empty?
                raise ArgumentError, 'invalid value'
              end
              @value = value
            end

            undef magnitude=
          end

          class DvDate < DvTemporal
            include OpenEHR::AssumedLibraryTypes::ISO8601DateModule

            DAYS_IN_MONTH = [0,31,28,31,30,31,30,31,31,30,31,30,31]

            def value=(value)
              super(value)
              iso8601_date = OpenEHR::AssumedLibraryTypes::ISO8601Date.new(value)
              @year = iso8601_date.year
              @month = iso8601_date.month
              @day = iso8601_date.day
            end

            def magnitude
              return Date.new(@year, @month, @day)-Date.new(0000,1,1)
            end

            def diff(other)
              if self.magnitude > other.magnitude
                past, future = other, self
              else
                past, future = self, other
              end
              year, month, day = 0, 0, 0
              if (future.day >= past.day)
                day = future.day - past.day
              else
                month = -1
                previous_month = future.month - 1
                if previous_month == 0
                  previous_month = 12
                end
                day = DAYS_IN_MONTH[previous_month] + future.day - past.day
                if leapyear?(future.year) && (previous_month == 2)
                  day += 1
                end
              end
              week = day / 7
              if (future.month >= past.month)
                month += future.month - past.month
              else
                year -= 1
                month += future.month + 12 - past.month
              end
              if month < 0
                year -= 1
                month += 12
              end
              year += future.year - past.year
              return DvDuration.new(:value =>
                   'P' + year.to_s + 'Y' + month.to_s + 'M' + 
                         week.to_s + 'W' + day.to_s + 'D')
            end
          end
          
          class DvTime < DvTemporal
            include OpenEHR::AssumedLibraryTypes::ISO8601TimeModule

            def value=(value)
              super(value)
              iso8601_time = OpenEHR::AssumedLibraryTypes::ISO8601Time.new(value)
              @hour = iso8601_time.hour
              @minute = iso8601_time.minute
              @second = iso8601_time.second
              @fractional_second = iso8601_time.fractional_second
              @timezone = iso8601_time.timezone
            end

            def magnitude
              if @fractional_second.nil? && @second.nil? && @minute.nil?
                return @hour * 60 * 60
              elsif @fractional_second.nil? && @second.nil?
                return @hour * 60 * 60 + @minute * 60
              elsif @fractional_second.nil?
                return @hour * 60 * 60 + @minute * 60 + @second
              else
                return @hour*60*60+@minute* 60 + @second + @fractional_second
              end
            end

            def diff(other)
              diff = (other.magnitude - self.magnitude).abs
              hour = (diff / 60 / 60).to_i
              minute = ((diff - hour*60*60)/60).to_i
              second = (diff - hour * 60 *60 - minute * 60).to_i
              fractional_second = ((diff - diff.to_i)*1000000.0).to_i/1000000.0
              str = 'P0Y0M0W0DT' + hour.to_s + 'H' +
                minute.to_s + 'M' + second.to_s
              if @fractional_second.nil?
                str += 'S'
              else
                str += fractional_second.to_s[1..-1] + 'S'
              end
              return DvDuration.new(:value => str)
            end
          end

          class DvDateTime < DvTemporal
            include OpenEHR::AssumedLibraryTypes::ISO8601DateTimeModule

            def value=(value)              
              super(value)
              iso8601date_time = OpenEHR::AssumedLibraryTypes::ISO8601DateTime.new(value)
              self.year = iso8601date_time.year
              self.month = iso8601date_time.month
              self.day = iso8601date_time.day
              self.minute = iso8601date_time.minute
              self.second = iso8601date_time.second
              self.hour = iso8601date_time.hour
              self.fractional_second = iso8601date_time.fractional_second
              self.timezone = iso8601date_time.timezone
            end

            def magnitude
              hour, minute = @hour, @minute
              if @timezone
                if @timezone.sign == -1
                  hour -= @timezone.hour
                  minute -= @timezone.minute
                elsif @timezone.sign == +1
                  hour += @timezone.hour
                  minute += @timezone.minute
                end
              end
              seconds = (((@year * 365.24 +
                           @month * 30.42 +
                           @day) * 24 +
                           hour) * 60 +
                           minute) * 60 + @second
              if @fractional_second.nil?
                return seconds
              else
                return seconds + @fractional_second
              end
            end

            def diff(other)
              if self.magnitude >= other.magnitude
                past, future = other, self
              else
                past, future = self, other
              end
              past_date, past_time = split_date_time(past)
              future_date, future_time = split_date_time(future)
              time_diff = future_time.magnitude - past_time.magnitude
              if future_time.magnitude < past_time.magnitude
                future_date.day = future_date.day - 1
                time_diff += 24 * 60 * 60
              end
              date_duration = past_date.diff(future_date)
              hour = (time_diff / 60 / 60).to_i
              minute = ((time_diff - hour*60*60)/60).to_i
              second = (time_diff - hour * 60 *60 - minute * 60).to_i
              str = date_duration.value + 'T' + hour.to_s + 'H' +
                minute.to_s + 'M' + second.to_s
              if @fractional_second.nil?
                return DvDuration.new(:value => str +'S')
              else
                fractional_second =
                  ((time_diff - time_diff.to_i)*1000000.0).to_i/1000000.0
                return DvDuration.new(:value => str +
                                      fractional_second.to_s[1..-1] + 'S')
              end
            end

            private
            def split_date_time(date_time)
              /^(.*)T(.*)$/ =~ date_time.as_string
              return DvDate.new(:value => $1), DvTime.new(:value => $2)
            end
          end

          class DvDuration < DvTemporal
            include OpenEHR::AssumedLibraryTypes::ISO8601DurationModule
            attr_reader :value
            
            def initialize(args = { })
              super
            end

            def value=(value)
              raise ArgumentError, 'value must be not nil' if value.nil?
              @value = value
              iso8601_duration = OpenEHR::AssumedLibraryTypes::ISO8601Duration.new(value)
              self.years = iso8601_duration.years
              self.months = iso8601_duration.months
              self.weeks = iso8601_duration.weeks
              self.days = iso8601_duration.days
              self.hours = iso8601_duration.hours
              self.minutes = iso8601_duration.minutes
              self.seconds = iso8601_duration.seconds
              self.fractional_second = iso8601_duration.fractional_second
            end

            def magnitude
              months = 0
              months += @months if @months
              months += @years * MONTH_IN_YEAR if @years
              days = 0
              days += months * NOMINAL_DAYS_IN_MONTH if months
              days += @weeks * DAYS_IN_WEEK if @weeks
              days += @days if @days
              hours = 0
              hours += days * HOURS_IN_DAY if days
              hours += @hours if @hours
              minutes = 0
              minutes += hours * MINUTES_IN_HOUR if hours
              minutes += @minutes if @minutes
              seconds = 0
              seconds += @seconds if @seconds
              seconds += @fractional_second if @fractional_second
              seconds += minutes * SECONDS_IN_MINUTE if minutes
              return seconds
            end
          end
        end # of DateTime
      end # of Quantity
    end # of Data_Types
  end # of RM
end # of OpenEHR
