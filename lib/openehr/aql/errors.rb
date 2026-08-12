# Error hierarchy for the AQL subsystem (parsing, semantic checks, and
# execution). Kept in its own file so lexer.rb/parser.rb/engine.rb can
# each require just this, without pulling in the rest of the subsystem.
module OpenEHR
  module AQL
    class Error < StandardError; end

    # Raised by the Lexer/Parser on malformed AQL source. Carries the
    # 1-based line/column of the offending token so the message can point
    # at the exact spot, e.g. "line 2, column 8: ...".
    class ParseError < Error
      attr_reader :line, :column

      def initialize(message, line: nil, column: nil)
        @line = line
        @column = column
        location = line && column ? " (line #{line}, column #{column})" : ''
        super("#{message}#{location}")
      end
    end

    class SemanticError < Error; end
    class UnboundParameterError < Error; end
    class ExecutionError < Error; end
    class DatasetError < Error; end
  end
end
