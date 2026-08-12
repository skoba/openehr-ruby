require 'json'
require_relative '../serializer/rm_json_serializer'

module OpenEHR
  module AQL
    # The output of Query#execute: column names plus rows (each row is an
    # Array positionally aligned with `columns`).
    class ResultSet
      include Enumerable

      attr_reader :columns, :rows

      def initialize(columns:, rows:)
        @columns = columns.freeze
        @rows = rows.freeze
        freeze
      end

      def each
        return enum_for(:each) unless block_given?

        rows.each { |row| yield row }
      end

      def size
        rows.size
      end

      # The openEHR REST Query API's result-set shape (columns/rows),
      # scoped to what's useful here rather than every optional metadata
      # field ("meta", "name", "q", ...) the full spec allows - add them
      # if/when a caller needs them. Each RM object row value is
      # expanded via RMJSONSerializer; JSON primitives (String/Numeric/
      # true/false/nil) pass through unchanged.
      def to_json(*args)
        {
          'columns' => columns.map { |name| { 'name' => name } },
          'rows' => rows.map { |row| row.map { |value| json_value(value) } }
        }.to_json(*args)
      end

      private

      def json_value(value)
        case value
        when nil, true, false, Numeric, String
          value
        else
          JSON.parse(Serializer::RMJSONSerializer.new(value).serialize)
        end
      end
    end
  end
end
