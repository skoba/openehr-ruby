# This module is related to the ticket #36
require 'date'
require 'time'

module OpenEHR
  module AssumedLibraryTypes
    class Any < Object
      
    end # of Any

    class Interval < Any
      attr_reader :lower, :upper
      
      def initialize(args = {})
        check_lower_upper(args[:lower], args[:upper])
        self.lower_included = args[:lower_included]
        self.upper_included = args[:upper_included]
      end

      def lower=(lower)
        check_lower_upper(lower, @upper)
      end

      def upper=(upper)
        check_lower_upper(@lower, upper)
      end

      def lower_included?
        return @lower_included
      end

      def lower_included=(lower_included)
        if (lower == nil) && (lower_included != nil)
          raise ArgumentError, "lower is not set"
        end
        @lower_included = lower_included
      end
      
      def lower_unbounded?
        return @lower.nil?
      end

      def upper_included?
        return @upper_included
      end

      def upper_included=(upper_included)
        if (@upper.nil?) && (upper_included != nil)
          raise ArgumentError, "upper is not set"
        end
        @upper_included = upper_included
      end

      def upper_unbounded?
        return @upper.nil?
      end

      def has?(value)
        if ((@lower.nil?||@lower < value||((@lower_included == true) && (@lower == value)))&&
            (@upper.nil?||value < @upper||((@upper_included == true) && (@upper == value))))
          true
        else
          false
        end
      end

      private

      def check_lower_upper(lower, upper)
        if lower.nil? && upper.nil?
          raise ArgumentError, "Either lower or upper must be assigned"
        end
        unless (lower.nil? || upper.nil?)
          if lower > upper
            raise ArgumentError, "Upper must be larger than lower."
          end
        end
        @lower = lower
        @upper = upper
      end
    end # end of Interval
  
    class TimeDefinitions < Any
      DAYS_IN_LEAP_YEAR = 366
      DAYS_IN_WEEK = 7
      DAYS_IN_YEAR = 365
      HOURS_IN_DAY = 24
      MAX_DAYS_IN_MONTH = 31
      MAX_DAYS_IN_YEAR = 366
      MINUTES_IN_HOUR = 60
      MONTH_IN_YEAR = 12
      NOMINAL_DAYS_IN_MONTH = 30.42
      NOMINAL_DAYS_IN_YEAR = 365.24
      SECONDS_IN_MINUTE = 60

      def self.valid_year?(year)
        return !year.nil? && year >= 0
      end

      def self.valid_day?(y, m, d)
        unless y.nil? || m.nil? || d.nil?
          return Date.valid_date?(y,m,d)
        end
        if (y.nil?) || (m.nil? && !d.nil?)
          return false
        end
        return self.valid_year?(y) && self.valid_month?(m)
      end

      def self.valid_hour?(h,m = nil, s = nil)
        if h.nil?
          return false
        end
        if !m.nil? and !valid_minute?(m)
          return false
        end
        if !s.nil? and (!m.nil? and !valid_second?(s))
          return false
        end
        (h >= 0 and h < HOURS_IN_DAY) or (h == HOURS_IN_DAY and m == 0 and s == 0)
      end

      def self.valid_minute?(mi)
        mi >= 0 and mi < MINUTES_IN_HOUR
      end

      def self.valid_second?(s)
        s >= 0 and s < SECONDS_IN_MINUTE
      end

      def self.valid_month?(mo)
        mo >= 1 and mo <= MONTH_IN_YEAR
      end

      protected
      def nilthenzero(value)
        return value ? value : 0
      end

    end # end of TimeDefinitions

    module ISO8601DateModule
      attr_reader :year, :month, :day

      def year=(year)
        unless ISO8601Date.valid_year?(year)
          raise ArgumentError, "Year is not valid"
        end
        @year = year
      end

      def month=(month)
        raise ArgumentError, "Month is not valid" unless month.nil? or ISO8601Date.valid_month?(month)
        @month = month
      end

      def day=(day)
        
        raise ArgumentError, "Day is not valid" unless day.nil? or ISO8601Date.valid_day?(@year, @month, day)
        @day = day
      end

      def as_string
        if (!@year.nil? and !@month.nil? and !@day.nil?)
          Date.new(@year, @month, @day).to_s
        elsif (!@year.nil? and !@month.nil? and @day.nil?)
          Date.new(@year, @month).to_s[0,7]
        elsif (!@year.nil? and @month.nil? and @day.nil?)
          Date.new(@year).to_s[0,4]
        end          
      end

      def to_days
        days = nilthenzero(@year)*TimeDefinitions::NOMINAL_DAYS_IN_YEAR +
          nilthenzero(@month)*TimeDefinitions::NOMINAL_DAYS_IN_MONTH +
          nilthenzero(@day)
        return days
      end

      def month_unknown?
        @month.nil?
      end

      def day_unknown?
        @day.nil?
      end

      def is_extended?
        true
      end

      def is_partial?
        month_unknown? or day_unknown?
      end
      
      protected
      def leapyear?(year)
        case
        when (year % 400) == 0 then true
        when (year % 100) == 0 then false
        else year % 4 == 0
        end
      end
    end

    class ISO8601Date < TimeDefinitions
      include ISO8601DateModule, Comparable
      def initialize(string)
        /(\d{4})(?:-(\d{2})(?:-(\d{2})?)?)?/ =~ string
        if $1.nil?
          raise ArgumentError, 'data invalid'
        else
          self.year = $1.to_i
        end
        if $2.nil?
          self.month = nil
        else
          self.month = $2.to_i
        end
        if $3.nil?
          self.day = nil
        else
          self.day = $3.to_i
        end
      end

      def <=>(other)
        self.to_days <=> other.to_days
      end

      def self.valid_iso8601_date?(string)
        begin
          Date.parse(string)
        rescue
          return false
        end
        true
      end
    end # end of ISO8601_DATE

    module ISO8601TimeModule
      attr_reader :hour, :minute, :second, :fractional_second, :timezone

      def hour=(hour)
        unless ISO8601Time.valid_hour?(hour, @minute, @second)
          raise ArgumentError, "hour is not valid"
        end
        @hour = hour
      end

      def minute_unknown?
        @minute.nil?
      end

      def minute=(minute)
        raise ArgumentError, "minute is not valid" if !minute.nil? and !ISO8601Time.valid_minute?(minute)
        @minute = minute
      end

      def second_unknown?
        @second.nil?
      end

      def second=(second)
        raise ArgumentError, "minute not defined" if @minute.nil? and !second.nil?
        raise ArgumentError, "second is not valid" if !second.nil? and !ISO8601Time.valid_second?(second)
        @second = second
      end

      def fractional_second=(fractional_second)
        raise ArgumentError, "minute not defined" if minute_unknown? and !fractional_second.nil?
        raise ArgumentError, "second not defined" if second_unknown? and !fractional_second.nil?
        if !fractional_second.nil? &&
            (fractional_second < 0.0 || fractional_second >= 1.0)
          raise ArgumentError, 'fractional second should be between 0.0 - 1.0'
        end
        @fractional_second = fractional_second
      end

      def has_fractional_second?
        return !@fractional_second.nil?
      end

      def timezone=(timezone)
        unless timezone.nil? or timezone == 'Z'
          if /[+-](\d{2}):?(\d{2})/ =~ timezone
            @timezone = timezone
          else
            raise ArgumentError, "timezone invalid"
          end
        else
          @timezone = nil
        end
      end

      def is_decimal_sign_comma?
        false
      end

      def is_extended?
        true
      end

      def is_partial?
        second_unknown? or minute_unknown?
      end

      def as_string
        s = sprintf("%02d", @hour)
        if !@minute.nil?
          s += ":" + sprintf("%02d",@minute)
          if !@second.nil?
            s += ":" + sprintf("%02d", @second)
            if !@fractional_second.nil?
              s += "." + @fractional_second.to_s[2..-1]
              if !@timezone.nil?
                s += @timezone
              end
            end
          end
        end
        return s
      end

      def to_second
        second = (nilthenzero(@hour)*60 + nilthenzero(@minute))*60 +
          nilthenzero(@second) +
          nilthenzero(@fractional_second)
        return second
      end
    end

    class ISO8601Time < TimeDefinitions
      include ISO8601TimeModule, Comparable
      def initialize(string)
        /(\d{2}):?(\d{2})?(:?)(\d{2})?((\.|,)(\d+))?(Z|([+-](\d{2}):?(\d{2})))?/ =~ string
        if $2.nil?
          self.minute = nil
        else
          self.minute = $2.to_i
        end
        if $4.nil?
          self.second = nil
        else
          self.second = $4.to_i
        end
        if $1.nil?
          raise ArgumentError, 'data invalid'
        else
          self.hour = $1.to_i
        end
        if $7.nil?
          self.fractional_second = nil
        else
          self.fractional_second = ("0." + $7).to_f
        end
        if $8.nil?
          self.timezone = nil
        else
          self.timezone = $8
        end
      end

      def <=>(other)
        self.to_second <=> other.to_second
      end

      def self.valid_iso8601_time?(s)
        if /^(\d{2}):?(\d{2})?(:?)(\d{2})?((\.|,)(\d+))?(Z|([+-](\d{2}):?(\d{2})))?$/ =~ s
# ISO 8601 regular expression by H. Yuki
#  http://digit.que.ne.jp/work/wiki.cgi?Perl%E3%83%A1%E3%83%A2%2FW3C%E5%BD%A2%E5%BC%8F%E3%81%AE%E6%97%A5%E6%99%82%E3%81%AE%E8%A7%A3%E6%9E%90
# (\d{4})(?:-(\d{2})(?:-(\d{2})(?:T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d))?)?(Z|([+-]\d{2}):(\d{2}))?)?)?)?
          hh = $1; mm = $2; ss = $4; msec = $7; tz = $8
          if hh.to_i == HOURS_IN_DAY and (mm.nil? or mm.to_i == 0) and (ss.nil? or ss.to_i == 0) and (msec.nil? or msec.to_i==0)
            return true
          end
          if hh.nil? or (hh.to_i < 0 or hh.to_i >= HOURS_IN_DAY)
            return false
          end
          if !mm.nil? 
            if !self.valid_minute?(mm.to_i)
              return false
            end
          end
          if !ss.nil? 
            if !self.valid_second?(ss.to_i)
              return false
            end
          end
          if !tz.nil? and tz != "Z"
            if /[+-](\d{2}):?(\d{2})/ =~ tz
              h = $1; m = $2
              if h.to_i < 0 or h.to_i >= HOURS_IN_DAY
                return false
              end
              if m.to_i < 0 or m.to_i >= MINUTES_IN_HOUR
                return false
              end
            end
          end
          return true
        else
          return false
        end
      end
    end # end of ISO8601_TIME

    module ISO8601DateTimeModule
      include ISO8601DateModule, ISO8601TimeModule
      def as_string
        if (!@year.nil? and !@month.nil? and !@day.nil?)
          s = Date.new(@year, @month, @day).to_s
        elsif (!@year.nil? and !@month.nil? and @day.nil?)
          return Date.new(@year, @month).to_s[0,7]
        elsif (!@year.nil? and @month.nil? and @day.nil?)
          return Date.new(@year).to_s[0,4]
        end
        unless hour.nil?
          s += sprintf("T%02d", @hour)
          unless @minute.nil?
            s += ":" + sprintf("%02d",@minute)
            unless @second.nil?
              s += ":" + sprintf("%02d", @second)
              unless @fractional_second.nil?
                s += "." + @fractional_second.to_s[2..-1]
                unless @timezone.nil?
                  s += @timezone
                end
              end
            end
          end
        end
        return s
      end
    end

    class ISO8601DateTime < ISO8601Date
      include ISO8601DateTimeModule
      def initialize(string)
        unless /(\d{4})(?:-(\d{2})(?:-(\d{2})(?:T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d+))?)?(Z|([+-]\d{2}):?(\d{2}))?)?)?)?/ =~ string
          raise ArgumentError, 'format invalid'
        else
          self.year = $1.to_i
        end
        if $2.nil?
          self.month = nil
        else
          self.month = $2.to_i
        end
        if $3.nil?
          self.day = nil
        else
          self.day = $3.to_i
        end
        if $5.nil?
          self.minute = nil
        else
          self.minute = $5.to_i
        end
        if $6.nil?
          self.second = nil
        else
          self.second = $6.to_i
        end
        if $4.nil?
          self.hour = nil
        else
          self.hour = $4.to_i
        end
        if $7.nil? or $7.empty?
          self.fractional_second = nil
        else
          self.fractional_second = ("0."+$7).to_f
        end
        if $8.nil?
          self.timezone = nil
        elsif $8 == 'Z'
          self.timezone = $8
        else
          self.timezone = $9+$10
        end
      end

      def <=>(other)
        self.magnitude <=> other.magnitude
      end

      protected
      def magnitude
        return self.to_days*HOURS_IN_DAY*MINUTES_IN_HOUR*SECONDS_IN_MINUTE +
          self.to_second
      end
    end
  
    class ISO8601Timezone
      attr_accessor :sign, :hour, :minute

      def initialize(string)
        unless /(Z|(([+-])(\d{2}):?(\d{2})))/ =~ string
          raise ArgumentError, 'invaild format'
        end
        if $1 == 'Z'
          @sign, @hour, @minute = +1, 0, 0
        else
          @sign, @hour, @minute = ($3+'1').to_i, $4.to_i , $5.to_i
        end
      end

      def is_gmt?
        @sign == +1 and @hour == 0 and @minute == 0
      end

      def as_string
        if @sign == +1
          s = "+"
        elsif @sign == -1
          s = "-"
        end
        sprintf("%s%02d%02d", s, @hour, @minute)
      end
    end # end of ISO8601Timezone

    module ISO8601DurationModule
      attr_reader :years, :months, :weeks, :days
      attr_reader :hours, :minutes, :seconds, :fractional_second

      def years=(years)
        unless years.nil? || years >= 0
          raise ArgumentError, 'years must be above zero'
        end
        @years = years
      end

      def months=(months)
        unless months.nil? || months >= 0
          raise ArgumentError, 'months must be above zero'
        end
        @months = months
      end

      def weeks=(weeks)
        unless weeks.nil? || weeks >= 0
          raise ArgumentError, 'weeks must be above zero'
        end
        @weeks = weeks
      end

      def days=(days)
        unless days.nil? || days >= 0
          raise ArgumentError, 'days must be above zero'
        end
        @days = days
      end

      def hours=(hours)
        unless hours.nil? || hours >= 0
          raise ArgumentError, 'hours must be above zero'
        end
        @hours = hours
      end

      def minutes=(minutes)
        unless minutes.nil? || minutes >= 0
          raise ArgumentError, 'minutes must be above zero'
        end
        @minutes = minutes
      end

      def seconds=(seconds)
        unless seconds.nil? || seconds >= 0
          raise ArgumentError, 'seconds must be above zero'
        end
        @seconds = seconds
      end

      def fractional_second=(fractional_second)
        unless fractional_second.nil? || (fractional_second >= 0 && fractional_second < 1.0)
          raise ArgumentError, 'fractional_second must be between 0.0 and 1.0'
        end
        @fractional_second = fractional_second
      end

      def as_string
        str = 'P'
        unless @years.nil?
          str += @years.to_s + 'Y'
        end
        unless @months.nil?
          str += @months.to_s + 'M'
        end
        unless @weeks.nil?
          str += @weeks.to_s + 'W'
        end
        unless @days.nil?
          str += @days.to_s + 'D'
        end
        unless @hours.nil?
          str += 'T' + @hours.to_s + 'H'
          unless @minutes.nil?
            str += @minutes.to_s + 'M'
            unless @seconds.nil?
              str += @seconds.to_s
              unless @fractional_second.nil?
                str += @fractional_second.to_s[1 .. -1]
              end
              str += 'S'
            end
          end
        end
        return str
      end
    end

    class ISO8601Duration < TimeDefinitions
      include ISO8601DurationModule
      def initialize(str)
        /^P((\d+)Y)?((\d+)M)?((\d+)W)?((\d)D)?(T((\d+)H)?((\d+)M)?((\d+)(\.\d+)?S)?)?$/ =~ str
        self.years = $2.to_i
        self.months = $4.to_i
        self.weeks = $6.to_i
        self.days = $8.to_i
        self.hours = $11.to_i
        self.minutes = $13.to_i
        self.seconds = $15.to_i
        unless $16.nil?
          self.fractional_second = $16.to_f
        end
      end
    end # end of ISO8601Duration
  end # end of Assumed_Types
end # end of OpenEHR
