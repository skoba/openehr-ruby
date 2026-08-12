require_relative 'errors'

# OpenEHR::AQL::Lexer tokenizes AQL source text, following the official
# ANTLR4 lexer grammar (AqlLexer.g4,
# https://specifications.openehr.org/releases/QUERY/latest/AQL.html) as
# the reference spec. It is a hand-written scanner (no parser-generator
# dependency is added) so that maximal-munch tie-breaks between
# overlapping token shapes - e.g. "openEHR-EHR-OBSERVATION.blood_pressure.v1"
# (ARCHETYPE_HRID) vs "openEHR" (IDENTIFIER), or "id5" (ID_CODE) vs "id5x"
# (IDENTIFIER) - can be resolved explicitly per token category, matching
# ANTLR's longest-match-wins / first-rule-wins-on-tie semantics.
#
# Scope (M0 milestone): keywords (case-insensitive), identifiers,
# ARCHETYPE_HRID, AT_CODE/ID_CODE, STRING, INTEGER/REAL/SCI_*, BOOLEAN,
# $PARAMETER, comparison operators, structural symbols, and '--' comments.
# DATE/TIME/DATETIME literals, TERM_CODE, URI, CONTAINED_REGEX and a
# Unicode BOM are deferred to the milestone that first needs them - none
# of the official AQL examples this gem targets require them yet.
module OpenEHR
  module AQL
    class Token
      attr_reader :type, :value, :line, :column

      def initialize(type, value, line:, column:)
        @type = type
        @value = value
        @line = line
        @column = column
        freeze
      end

      def ==(other)
        other.is_a?(Token) && type == other.type && value == other.value
      end
      alias eql? ==

      def hash
        [type, value].hash
      end

      def to_s
        "#{type}(#{value.inspect})@#{line}:#{column}"
      end
    end

    class Lexer
      KEYWORDS = {
        'select' => :select, 'as' => :as, 'from' => :from, 'where' => :where,
        'order' => :order, 'by' => :by, 'desc' => :desc, 'descending' => :descending,
        'asc' => :asc, 'ascending' => :ascending, 'limit' => :limit, 'offset' => :offset,
        'distinct' => :distinct, 'version' => :version, 'latest_version' => :latest_version,
        'all_versions' => :all_versions, 'null' => :null,
        'top' => :top, 'forward' => :forward, 'backward' => :backward,
        'contains' => :contains, 'and' => :and, 'or' => :or, 'not' => :not, 'exists' => :exists,
        'like' => :like, 'matches' => :matches,
        'count' => :count, 'min' => :min, 'max' => :max, 'sum' => :sum, 'avg' => :avg,
        'terminology' => :terminology,
        'length' => :length, 'position' => :position, 'substring' => :substring,
        'concat' => :concat, 'concat_ws' => :concat_ws,
        'abs' => :abs, 'mod' => :mod, 'ceil' => :ceil, 'floor' => :floor, 'round' => :round,
        'now' => :now, 'current_date' => :current_date, 'current_time' => :current_time,
        'current_date_time' => :current_date_time, 'current_timezone' => :current_timezone
      }.freeze

      ARCHETYPE_HRID_RE = /\A[A-Za-z][A-Za-z0-9_]*-[A-Za-z][A-Za-z0-9_]*-[A-Za-z][A-Za-z0-9_]*
                            \.[A-Za-z][A-Za-z0-9_-]*
                            \.v\d+(?:\.\d+)*(?:-(?:rc|alpha)(?:\.\d+)?)?/x
      AT_ID_CODE_RE = /\A(?:at|id)\d+(?:\.\d+)*/
      IDENTIFIER_RE = /\A[A-Za-z][A-Za-z0-9_]*/
      NUMBER_RE = /\A(?:\d*\.\d+|\d+)(?:[eE][+-]?\d+)?/

      ESCAPES = {
        '\\' => "\\", "'" => "'", '"' => '"', '?' => '?',
        'a' => "\a", 'b' => "\b", 'f' => "\f", 'n' => "\n",
        'r' => "\r", 't' => "\t", 'v' => "\v"
      }.freeze

      SYMBOLS = {
        ',' => :comma, '/' => :slash, '*' => :asterisk, '+' => :plus,
        '(' => :left_paren, ')' => :right_paren,
        '[' => :left_bracket, ']' => :right_bracket,
        '{' => :left_curly, '}' => :right_curly
      }.freeze

      def initialize(source)
        raise ArgumentError, 'source must be a String' unless source.is_a?(String)

        @chars = source.chars
        @pos = 0
        @line = 1
        @column = 1
      end

      def tokenize
        tokens = []
        loop do
          skip_whitespace_and_comments
          start_line, start_column = @line, @column
          if at_end?
            tokens << Token.new(:eof, nil, line: start_line, column: start_column)
            break
          end
          tokens << next_token(start_line, start_column)
        end
        tokens.freeze
      end

      private

      def at_end?
        @pos >= @chars.length
      end

      def peek(offset = 0)
        @chars[@pos + offset]
      end

      def advance
        c = @chars[@pos]
        @pos += 1
        if c == "\n"
          @line += 1
          @column = 1
        else
          @column += 1
        end
        c
      end

      def remaining
        @chars[@pos..].join
      end

      def skip_whitespace_and_comments
        loop do
          if !at_end? && peek =~ /[ \t\r\n]/
            advance
          elsif peek == '-' && peek(1) == '-' && comment_ahead?
            skip_comment
          else
            break
          end
        end
      end

      # A "--" starts a COMMENT only when followed by a space (a
      # "-- text" line comment) or immediately by newline/EOF (an empty
      # comment). Any other following character means the "--" itself is
      # a SYM_DOUBLE_DASH token, handled by next_token instead.
      def comment_ahead?
        after = peek(2)
        after.nil? || after == ' ' || after == "\n" || after == "\r"
      end

      def skip_comment
        advance # first '-'
        advance # second '-'
        advance while !at_end? && peek != "\n"
      end

      def next_token(line, column)
        c = peek
        return read_string(line, column) if c == "'" || c == '"'
        return read_parameter(line, column) if c == '$'
        return read_number(line, column) if c =~ /\d/
        return read_word(line, column) if c =~ /[A-Za-z]/
        return read_double_dash_or_symbol(line, column) if c == '-'
        return read_comparison_operator(line, column) if c =~ /[=!<>]/
        return read_symbol(line, column) if SYMBOLS.key?(c)

        raise ParseError.new("unexpected character #{c.inspect}", line: line, column: column)
      end

      def read_word(line, column)
        hrid = ARCHETYPE_HRID_RE.match(remaining)&.to_s
        at_id = AT_ID_CODE_RE.match(remaining)&.to_s
        plain = IDENTIFIER_RE.match(remaining)&.to_s

        candidates = [
          [hrid, :archetype_hrid, 0],
          [at_id, :at_id_code, 1],
          [plain, :plain_word, 2]
        ].select { |text, _type, _pri| text }
        text, kind, = candidates.max_by { |t, _k, pri| [t.length, -pri] }

        text.length.times { advance }

        case kind
        when :archetype_hrid
          Token.new(:archetype_hrid, text, line: line, column: column)
        when :at_id_code
          type = text.start_with?('at') ? :at_code : :id_code
          Token.new(type, text, line: line, column: column)
        else
          build_word_token(text, line, column)
        end
      end

      def build_word_token(text, line, column)
        downcased = text.downcase
        if downcased == 'true' || downcased == 'false'
          Token.new(:boolean, downcased == 'true', line: line, column: column)
        elsif KEYWORDS.key?(downcased)
          Token.new(KEYWORDS[downcased], text, line: line, column: column)
        else
          Token.new(:identifier, text, line: line, column: column)
        end
      end

      def read_number(line, column)
        text = NUMBER_RE.match(remaining).to_s
        text.length.times { advance }
        real = text.include?('.')
        sci = text =~ /[eE]/
        type = if real && sci
                 :sci_real
               elsif real
                 :real
               elsif sci
                 :sci_integer
               else
                 :integer
               end
        value = real || sci ? Float(text) : Integer(text)
        Token.new(type, value, line: line, column: column)
      end

      def read_string(line, column)
        quote = advance
        buffer = +''
        loop do
          raise ParseError.new('unterminated string literal', line: line, column: column) if at_end?

          ch = advance
          if ch == quote
            break
          elsif ch == '\\'
            raise ParseError.new('unterminated string literal', line: line, column: column) if at_end?

            esc = advance
            buffer << (ESCAPES[esc] || esc)
          else
            buffer << ch
          end
        end
        Token.new(:string, buffer, line: line, column: column)
      end

      def read_parameter(line, column)
        advance # '$'
        name = IDENTIFIER_RE.match(remaining)&.to_s
        if name.nil? || name.empty?
          raise ParseError.new('expected an identifier after $', line: line, column: column)
        end

        name.length.times { advance }
        Token.new(:parameter, name, line: line, column: column)
      end

      def read_double_dash_or_symbol(line, column)
        if peek(1) == '-'
          advance
          advance
          Token.new(:double_dash, '--', line: line, column: column)
        else
          advance
          Token.new(:minus, '-', line: line, column: column)
        end
      end

      def read_comparison_operator(line, column)
        c = advance
        if (c == '!' || c == '<' || c == '>') && peek == '='
          advance
          Token.new(:comparison_operator, "#{c}=", line: line, column: column)
        elsif c == '!'
          raise ParseError.new("unexpected character \"!\"", line: line, column: column)
        else
          Token.new(:comparison_operator, c, line: line, column: column)
        end
      end

      def read_symbol(line, column)
        c = advance
        Token.new(SYMBOLS.fetch(c), c, line: line, column: column)
      end
    end
  end
end
