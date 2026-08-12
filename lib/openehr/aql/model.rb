# OpenEHR::AQL::Model holds the immutable object model that the Parser
# builds and the execution Engine walks: one class per relevant
# AqlParser.g4 rule (see lib/openehr/aql/parser.rb for the mapping).
require_relative 'model/query'
require_relative 'model/select_clause'
require_relative 'model/from_clause'
require_relative 'model/identified_path'
require_relative 'model/literal'
require_relative 'model/object_path'
require_relative 'model/predicate'
require_relative 'model/containment'
require_relative 'model/where_clause'
require_relative 'model/order_by_and_limit'
require_relative 'model/function_call'
