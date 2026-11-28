module OpenEHR
  module AQL
    # How AQL compares date and date-time values (R-20261128-11, #161).
    # The specification (QUERY 3.12.5) does not say how partial values or
    # values in different offsets compare; this is this implementation's
    # rule, kept in one place:
    #
    # WHERE (compare): split each value into its written components, year
    # to second (a fraction belongs to the second). Compare from the year
    # on, only the components both sides have; the first difference
    # decides, and equal down to the common precision is equal. Both
    # sides are converted to UTC first only when both have an offset;
    # otherwise they are compared as written.
    #
    # ORDER BY (order_key): a total order is needed, so by earliest
    # instant (missing components lowest, no offset read as UTC), then the
    # coarser value first, then the written string.
    #
    # The RM types' own <=> and magnitude are not changed by this.
    module TemporalComparison
      DATE_TIME = OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime
      DATE = OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate
      DATE_TYPES = [DATE_TIME, DATE].freeze

      # The written components of one value, and its UTC offset in
      # seconds (nil when it has none). text is the value as written.
      Value = Struct.new(:components, :offset, :text)

      module_function

      def temporal?(value)
        DATE_TYPES.any? { |klass| value.is_a?(klass) }
      end

      # A DvDateTime, a DvDate or an ISO 8601 date or date-time String,
      # as a Value; nil when it cannot be read as a date or a date-time.
      def parse(value)
        text = value.is_a?(String) ? value : value.value
        if value.is_a?(DATE)
          from_date(OpenEHR::AssumedLibraryTypes::ISO8601Date.new(text), text)
        else
          from_date_time(OpenEHR::AssumedLibraryTypes::ISO8601DateTime.new(text), text)
        end
      rescue ArgumentError
        nil
      end

      # -1, 0 or 1 by the WHERE rule.
      def compare(a, b)
        a, b = in_utc(a), in_utc(b) if a.offset && b.offset
        a.components.zip(b.components).each do |x, y|
          break if x.nil? || y.nil?

          cmp = x <=> y
          return cmp unless cmp.zero?
        end
        0
      end

      def order_key(value)
        [earliest_utc(value), value.components.size, value.text]
      end

      def from_date(date, text)
        Value.new([date.year, date.month, date.day].take_while { |c| !c.nil? }, nil, text)
      end

      def from_date_time(date_time, text)
        second = date_time.second && (date_time.second + Rational((date_time.fractional_second || 0).to_s))
        components = [date_time.year, date_time.month, date_time.day, date_time.hour, date_time.minute, second]
        Value.new(components.take_while { |c| !c.nil? }, offset_seconds(date_time.timezone), text)
      end

      def offset_seconds(timezone)
        text = timezone&.to_s
        return nil if text.nil? || text.empty?
        return 0 if text == 'Z'

        match = /\A([+-])(\d{2})(?::?(\d{2}))?\z/.match(text)
        return nil unless match

        sign = match[1] == '-' ? -1 : 1
        sign * ((match[2].to_i * 3600) + (match[3].to_i * 60))
      end

      # The same instant in UTC, cut back to the precision it was
      # written with: missing minutes and seconds count as 0 for the
      # conversion only. A value with an offset always has an hour.
      def in_utc(value)
        utc = filled_time(value) - value.offset
        second = utc.sec + utc.subsec
        all = [utc.year, utc.month, utc.day, utc.hour, utc.min, second]
        Value.new(all.first(value.components.size), 0, value.text)
      end

      def earliest_utc(value)
        filled_time(value) - (value.offset || 0)
      end

      def filled_time(value)
        year, month, day, hour, minute, second = value.components
        Time.utc(year, month || 1, day || 1, hour || 0, minute || 0, second || 0)
      end
    end
  end
end
