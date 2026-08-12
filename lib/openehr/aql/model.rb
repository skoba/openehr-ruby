# OpenEHR::AQL::Model holds the immutable object model that the Parser
# builds and the execution Engine walks: one class per relevant
# AqlParser.g4 rule (see lib/openehr/aql/parser.rb for the mapping).
require_relative 'model/query'
require_relative 'model/select_clause'
require_relative 'model/from_clause'
require_relative 'model/identified_path'
require_relative 'model/literal'
