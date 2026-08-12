module OpenEHR
  module AQL
    # The output of Query#execute: column names plus rows (each row is an
    # Array positionally aligned with `columns`). #to_json (the openEHR
    # REST Query API result-set format) is added once the engine covers
    # enough of the language for it to be meaningful.
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
    end
  end
end
