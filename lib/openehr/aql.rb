require_relative 'aql/errors'
require_relative 'aql/lexer'
require_relative 'aql/model'
require_relative 'aql/parser'
require_relative 'aql/engine/dataset'

# OpenEHR::AQL is the Archetype Query Language subsystem: a hand-written
# lexer/parser producing a Query object model (see the project plan's
# "AQLサブシステム設計" section), plus an in-memory execution engine that
# evaluates queries against Dataset (framework/ORM-agnostic; see
# lib/openehr/aql/engine/dataset.rb).
#
# Public API (module-level entry points are added as later milestones
# land):
#   OpenEHR::AQL.parse(aql_string) -> Model::Query
module OpenEHR
  module AQL
    def self.parse(source)
      Parser.new(Lexer.new(source).tokenize).parse_select_query
    end
  end
end
