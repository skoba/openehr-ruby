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
        if (lower.nil?) && (!lower_included.nil?)
          raise ArgumentError, "lower is not set"
        end
        lower_included = true if !lower.nil? && lower_included.nil?
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
        upper_included = true if !upper.nil? && upper_included.nil?
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

      def ==(value)
        return (@lower == value.lower) && (@upper == value.upper) &&
          (@lower_included == value.lower_included?) &&
            (@upper_included == value.upper_included?)
      end

      # True if every value this interval has is also had by other (a
      # standard subset test, e.g. for conformance checks: does a
      # constraint's occurrences/existence/cardinality interval fit
      # within its parent's).
      def subset_of?(other)
        return false if other.nil?

        lower_ok = if lower_unbounded?
                     other.lower_unbounded?
                   elsif other.lower_unbounded? || lower > other.lower
                     true
                   elsif lower == other.lower
                     !lower_included? || other.lower_included?
                   else
                     false
                   end
        upper_ok = if upper_unbounded?
                     other.upper_unbounded?
                   elsif other.upper_unbounded? || upper < other.upper
                     true
                   elsif upper == other.upper
                     !upper_included? || other.upper_included?
                   else
                     false
                   end
        lower_ok && upper_ok
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

    class Timezone
      attr_reader :hour, :minute, :value

      def initialize(value)
        self.value = value
      end

      def value=(value)
        unless value.nil?
          if /((([+-](\d{2}))(?::?(\d{2}))?)|Z)/ =~ value
            @value = value
            if $1 == 'Z'
              @hour, @minute = 0,0
            else
              @hour = $3.to_i
              @minute = $5.to_i
            end
          else
            raise ArgumentError, "timezone invalid"
          end
        else
          @value = nil
        end
      end

      def sign
        unless @hour
          return nil
        end
        if @hour < 0
          return -1
        else
          return +1
        end
      end

      def to_s
        return value
      end

      alias_method :as_string, :to_s
      alias_method :hours, :hour
      alias_method :minutes, :minute
    end

    module TimeDefinitions #< Any
      DAYS_IN_LEAP_YEAR = 366
      DAYS_IN_WEEK = 7
      DAYS_IN_MONTH = 30
      DAYS_IN_YEAR = 365
      HOURS_IN_DAY = 24
      MAX_DAYS_IN_MONTH = 31
      MAX_DAYS_IN_YEAR = 366
      MINUTES_IN_HOUR = 60
      MONTH_IN_YEAR = 12
      NOMINAL_DAYS_IN_MONTH = 30.42
      NOMINAL_DAYS_IN_YEAR = 365.24
      SECONDS_IN_MINUTE = 60
      # Julian day number of 0001-01-01 on the proleptic Gregorian
      # calendar, the origin of the ordering count (#117, #120).
      CALENDAR_ORIGIN_JD = Date.new(1, 1, 1, Date::GREGORIAN).jd

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
      include TimeDefinitions
      attr_reader :year, :month, :day

      def year=(year)
        unless TimeDefinitions.valid_year?(year)
          raise ArgumentError, "Year is not valid"
        end
        @year = year
      end

      def month=(month)
        raise ArgumentError, "Month is not valid" unless month.nil? or TimeDefinitions.valid_month?(month)
        @month = month
      end

      def day=(day)
        
        raise ArgumentError, "Day is not valid" unless day.nil? or TimeDefinitions.valid_day?(@year, @month, day)
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
        days = (nilthenzero(@year)*TimeDefinitions::NOMINAL_DAYS_IN_YEAR) +
          (nilthenzero(@month)*TimeDefinitions::NOMINAL_DAYS_IN_MONTH) +
          nilthenzero(@day)
        return days
      end

      def month_unknown?
        @month.nil?
      end

      def day_unknown?
        @day.nil?
      end

      # True if the value was given in the extended form (with '-' and
      # ':' separators), false for the compact form (BASE Foundation
      # Types 6.5.3-6.5.6; #80). A value that cannot show a separator
      # (a year only, an hour only) counts as extended.
      def is_extended?
        @extended.nil? ? true : @extended
      end

      def is_partial?
        month_unknown? or day_unknown?
      end
      
      def leapyear?(year)
        case
        when (year % 400) == 0 then true
        when (year % 100) == 0 then false
        else year % 4 == 0
        end
      end

      protected

      # The ordering count of the date and date-time classes (#120): days
      # since 0001-01-01 on the proleptic Gregorian calendar, the origin
      # RM Data Types 7.2.2 gives DV_DATE.magnitude. ISO8601Date,
      # ISO8601DateTime and DvDateTime all order by it (DvDate: see its
      # magnitude); #to_days is a nominal count and is not used for order.
      #
      # A missing month or day counts as 1, here only, so a partial value
      # (2026, 2026-11) orders as its earliest instant. The value and its
      # string keep their precision: nothing is written back. The
      # specification does not say how a partial value is ordered (RM
      # Data Types 7.2; BASE Foundation Types 6.5 says only that the date
      # and time types are ordered); this follows EHRbase, which fills
      # the smallest value for magnitude and keeps the original string
      # (openEHR Discourse "CDR implementation of partial DV_TEMPORALs",
      # https://discourse.openehr.org/t/cdr-implementation-of-partial-dv-temporals/11954 ).
      # See also #59 (https://discourse.openehr.org/t/one-clinical-time-many-precisions-should-dv-date-time-hold-date-only-and-year-only-values/17524 ).
      # To be revisited if those discussions reach a conclusion.
      #
      # Ordering equality is not value equality: 2026 and 2026-01-01
      # order the same (and are == through Comparable), but their #value
      # (or #as_string) differs. Compare that to tell precisions apart.
      def calendar_days
        Date.new(@year, @month || 1, @day || 1, Date::GREGORIAN).jd - CALENDAR_ORIGIN_JD
      end
    end

    class ISO8601Date
      include ISO8601DateModule, Comparable

      EXTENDED_FORM = /\A(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?\z/
      COMPACT_FORM = /\A(\d{4})(\d{2})(\d{2})?\z/

      def initialize(string)
        # Anchored (issue #72): YYYY, YYYY-MM or YYYY-MM-DD, or the
        # compact YYYYMMDD or YYYYMM (#80), and nothing else.
        if EXTENDED_FORM =~ string
          @extended = true
        elsif COMPACT_FORM =~ string
          @extended = false
        else
          raise ArgumentError, 'data invalid'
        end
        self.year = $1.to_i
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

      # By the calendar count (#120); see ISO8601DateModule#calendar_days.
      def <=>(other)
        self.calendar_days <=> other.calendar_days
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
      include TimeDefinitions
      attr_reader :hour, :minute, :second, :fractional_second

      def hour=(hour)
        unless TimeDefinitions.valid_hour?(hour, @minute, @second)
          raise ArgumentError, "hour is not valid"
        end
        @hour = hour
      end

      def minute_unknown?
        @minute.nil?
      end

      def minute=(minute)
        raise ArgumentError, "minute is not valid" if !minute.nil? and !TimeDefinitions.valid_minute?(minute)
        @minute = minute
      end

      def second_unknown?
        @second.nil?
      end

      def second=(second)
        raise ArgumentError, "minute not defined" if @minute.nil? and !second.nil?
        raise ArgumentError, "second is not valid" if !second.nil? and !TimeDefinitions.valid_second?(second)
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
        unless timezone.nil? or timezone.empty?
          @timezone = Timezone.new(timezone)
        else
          @timezone = nil
        end
      end

      def timezone
        @timezone.to_s
      end

      def is_decimal_sign_comma?
        false
      end

      # True if the value was given in the extended form (with '-' and
      # ':' separators), false for the compact form (BASE Foundation
      # Types 6.5.3-6.5.6; #80). A value that cannot show a separator
      # (a year only, an hour only) counts as extended.
      def is_extended?
        @extended.nil? ? true : @extended
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
            end
          end
        end
        # The offset is written whatever the precision (#121).
        s += @timezone.to_s unless @timezone.nil?
        return s
      end

      def to_second
        second = (((nilthenzero(@hour)*60) + nilthenzero(@minute))*60) +
          nilthenzero(@second) +
          nilthenzero(@fractional_second)
        return second
      end
    end

    class ISO8601Time
      include ISO8601TimeModule, Comparable
      def initialize(string)
        # hhmm... is the compact form (#80); a bare hh counts as extended.
        @extended = !(/\A\d{4}/ =~ string)
        /^(\d{2}):?(\d{2})?(:?)(\d{2})?((\.|,)(\d+))?(Z|([+-](\d{2})(?::?(\d{2}))?))?$/ =~ string
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

      # Compares as written: the UTC offset is ignored, because a time has
      # no date and normalising it to UTC can cross midnight (#113).
      # ISO8601DateTime does normalise (#112).
      def <=>(other)
        self.to_second <=> other.to_second
      end

      def self.valid_iso8601_time?(s)
        if /^(\d{2}):?(\d{2})?(:?)(\d{2})?((\.|,)(\d+))?(Z|([+-](\d{2})(?::?(\d{2}))?))?$/ =~ s
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
            if !TimeDefinitions.valid_minute?(mm.to_i)
              return false
            end
          end
          if !ss.nil? 
            if !TimeDefinitions.valid_second?(ss.to_i)
              return false
            end
          end
          # A timezone is optional in ISO 8601; its absence does not make an
          # otherwise-valid time invalid.
          return false unless valid_timezone_part?(tz)

          return true
        end
      end

      def self.valid_timezone_part?(tz)
        return true if tz.nil?

        timezone = Timezone.new(tz)
        return false if timezone.hour < 0 or timezone.hour >= HOURS_IN_DAY
        return false if timezone.minute < 0 or timezone.minute >= MINUTES_IN_HOUR

        true
      end
    end # end of ISO8601_TIME

    module ISO8601DateTimeModule
      include ISO8601DateModule, ISO8601TimeModule
      
      def hour_unknown?
        @hour.nil?
      end

      # A date-time may have no time part at all (YYYY-MM-DD, YYYY-MM,
      # YYYY; issue #59), so the hour may be nil here, unlike in a time.
      def hour=(hour)
        if hour.nil?
          @hour = nil
        else
          super
        end
      end

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
              end
            end
          end
          unless @timezone.nil?
            s += @timezone.to_s
          end
        end
        return s
      end

      protected

      # Seconds since 0001-01-01T00:00:00Z (RM Data Types 7.2.4), the
      # ordering count of ISO8601DateTime and DvDateTime (#117, #120):
      # calendar days, then the time of day (a missing hour, minute or
      # second counts as 0, here only), minus the UTC offset (#108).
      def utc_seconds
        ((((((calendar_days * HOURS_IN_DAY) + (@hour || 0)) * MINUTES_IN_HOUR) +
           (@minute || 0)) * SECONDS_IN_MINUTE) + (@second || 0)) +
          (@fractional_second || 0) - utc_offset_seconds
      end

      private

      # The offset in seconds, east of UTC positive. Read from the offset
      # text, because Timezone#hour loses the sign of "-00:30" and
      # Timezone#minute is unsigned (#108). Z and a value without an
      # offset both give 0, so a value without an offset counts as UTC,
      # also when it is compared with a value that has one (#112). An
      # hour-only offset (±hh) counts whole hours (#137).
      def utc_offset_seconds
        return 0 unless @timezone

        match = /\A([+-])(\d{2})(?::?(\d{2}))?\z/.match(@timezone.to_s)
        return 0 unless match

        seconds = (match[2].to_i * MINUTES_IN_HOUR * SECONDS_IN_MINUTE) + (match[3].to_i * SECONDS_IN_MINUTE)
        match[1] == '-' ? -seconds : seconds
      end
    end

    class ISO8601DateTime
      include ISO8601DateTimeModule, Comparable

      # Both forms capture the same groups: year, month, day, hour,
      # minute, second, decimal sign, fraction, offset.
      EXTENDED_FORM = /\A(\d{4})(?:-(\d{2})(?:-(\d{2})(?:T(\d{2})(?::(\d{2})(?::(\d{2})(?:(\.|,)(\d+))?)?(Z|([+-]\d{2})(?::?(\d{2}))?)?)?)?)?)?\z/
      COMPACT_FORM = /\A(\d{4})(\d{2})(?:(\d{2})(?:T(\d{2})(?:(\d{2})(?:(\d{2})(?:(\.|,)(\d+))?)?(Z|([+-]\d{2})(\d{2})?)?)?)?)?\z/

      def initialize(string)
        # Anchored, and the date must be complete before a time may follow
        # (issue #72): unanchored, any string containing a date-time passed
        # and the rest was dropped.
        #
        # The time part, and the day and month, may be missing (YYYY-MM-DD,
        # YYYY-MM, YYYY; issue #59), so a value known only to the day or
        # the year is kept at that precision instead of a time of day being
        # made up. openEHR BASE Foundation Types is not consistent here:
        # section 6.2 ("Partial variants of Iso8601_date_time can include
        # missing hours, days and months") and the Iso8601_date_time class
        # description allow it; valid_iso8601_date_time and the class
        # invariants (Partial_validity_hour: not hour_unknown, ...) do not.
        # This implementation follows the former.
        # Raised upstream as a specification question (2026-11-26):
        # https://discourse.openehr.org/t/one-clinical-time-many-precisions-should-dv-date-time-hold-date-only-and-year-only-values/17524
        #
        # The compact form (YYYYMMDDThhmmss..., YYYYMMDD, YYYYMM; BASE
        # Foundation Types 6.5.1) is read too (#80). The date part and the
        # time part use one form; a value that mixes them is rejected.
        if EXTENDED_FORM =~ string
          @extended = true
        elsif COMPACT_FORM =~ string
          @extended = false
        else
          raise ArgumentError, 'format invalid'
        end
        self.year = $1.to_i
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
        if $8.nil? or $8.empty?
          self.fractional_second = nil
        else
          self.fractional_second = ("0."+$8).to_f
        end
        if $9.nil?
          self.timezone = nil
        else
          self.timezone = $9
        end
      end

      def <=>(other)
        self.magnitude <=> other.magnitude
      end

      protected
      # The UTC instant (#112), counted as DvDateTime#magnitude is
      # (#117, #120): see ISO8601DateTimeModule#utc_seconds.
      def magnitude
        utc_seconds
      end
    end
  
    class ISO8601Timezone
      def initialize(string)
        @timezone = Timezone.new(string)
      end

      def hour
        return @timezone.hour
      end

      def minute
        return @timezone.minute
      end

      def sign
        if @timezone.hour < 0
          return -1
        else
          return +1
        end
      end

      def is_gmt?
        return (@timezone.hour == 0 and @timezone.minute == 0)
      end

      def as_string
        if @timezone.hour < 0
          s = ''
        else
          s = '+'
        end
        sprintf("%s%02d%02d", s, @timezone.hour, @timezone.minute)
      end

      alias to_s as_string
      alias gmt? is_gmt?
    end # end of ISO8601Timezone

    module ISO8601DurationModule
      include TimeDefinitions
      attr_reader :years, :months, :weeks, :days
      attr_reader :hours, :minutes, :seconds, :fractional_second
      # RM 1.1.0 (SPECRM-96): a leading '-' before 'P' negates the whole
      # duration (e.g. "-P10D", 10 days before an unstated origin point).
      # Components stay non-negative magnitudes - the sign applies to
      # the duration as a whole, not each field - so it's tracked here.
      attr_reader :negative

      def negative=(negative)
        @negative = negative ? true : false
      end

      def negative?
        @negative == true
      end

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
        str = negative? ? '-P' : 'P'
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

      def to_seconds
        days = (nilthenzero(@years)*TimeDefinitions::DAYS_IN_YEAR) +
          (nilthenzero(@months)*TimeDefinitions::DAYS_IN_MONTH) +
          (nilthenzero(@weeks)*TimeDefinitions::DAYS_IN_WEEK) + 
          nilthenzero(@days)
        seconds_with_fractional = (((((days*TimeDefinitions::HOURS_IN_DAY) + nilthenzero(@hours))*TimeDefinitions::MINUTES_IN_HOUR)+nilthenzero(@minutes))*TimeDefinitions::SECONDS_IN_MINUTE) +
          nilthenzero(@seconds) +
          @fractional_second.to_f
        return negative? ? -seconds_with_fractional : seconds_with_fractional
      end
    end

    class ISO8601Duration
      include ISO8601DurationModule, Comparable
      def initialize(str)
        # A leading '-' negates the whole duration (RM 1.1.0, SPECRM-96);
        # stripped before the main match so the existing capture group
        # numbering below doesn't need to shift.
        self.negative = str.start_with?('-')
        duration_str = negative? ? str[1..-1] : str
        md = /^P((\d+)[Yy])?((\d+)[Mm])?((\d+)[Ww])?((\d+)[dD])?(T((\d+)[Hh])?((\d+)[Mm])?((\d+)(\.\d+)?[Ss])?)?$/.match(duration_str)
        if md.nil?
          raise ArgumentError, 'invalid ISO8601 duration format'
        end
        # Absent components stay nil rather than being coerced to 0, so
        # as_string can round-trip a partially-specified duration and
        # "unset" is distinguishable from "explicitly zero".
        self.years = md[2] && md[2].to_i
        self.months = md[4] && md[4].to_i
        self.weeks = md[6] && md[6].to_i
        self.days = md[8] && md[8].to_i
        self.hours = md[11] && md[11].to_i
        self.minutes = md[13] && md[13].to_i
        self.seconds = md[15] && md[15].to_i
        self.fractional_second = md[16] && md[16].to_f
      end

      def <=>(other)
        self.to_seconds <=> other.to_seconds
      end
    end # end of ISO8601Duration
  end # end of Assumed_Types
end # end of OpenEHR
