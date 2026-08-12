require_relative 'aql/errors'
require_relative 'aql/lexer'
require_relative 'aql/model'
require_relative 'aql/parser'
require_relative 'aql/engine/dataset'
require_relative 'aql/engine'

# OpenEHR::AQL is the Archetype Query Language subsystem: a hand-written
# lexer/parser producing a Query object model (see the project plan's
# "AQLサブシステム設計" section), plus an in-memory execution engine that
# evaluates queries against Dataset (framework/ORM-agnostic; see
# lib/openehr/aql/engine/dataset.rb).
#
# Public API:
#   OpenEHR::AQL.parse(aql_string) -> Model::Query
#   query.execute(dataset, params: {}) -> ResultSet
#   OpenEHR::AQL.execute(aql_string, dataset, params: {}) -> ResultSet
module OpenEHR
  module AQL
    def self.parse(source)
      Parser.new(Lexer.new(source).tokenize).parse_select_query
    end

    def self.execute(source, dataset, params: {})
      parse(source).execute(dataset, params: params)
    end
  end
end
