# OpenEHR::Path parses the openEHR archetype path syntax used to
# navigate LOCATABLE/PATHABLE trees, e.g.
#   /content[at0001]/data[at0002]/events[at0006]/data[at0003]/items[at0004, 'Systolic']/value
#
# Grammar subset supported (see the plan for the full rationale):
#   path      := '/' | ('/' segment)+
#   segment   := attribute predicate?
#   attribute := [a-z][a-zA-Z0-9_]*
#   predicate := '[' node_id (',' ws* name)? ']'
#   node_id   := at-code (at\d+(\.\d+)*, incl. specialised at0001.1 and
#                the short at0.2 form ADL 1.4 uses for nodes newly
#                introduced by a specialisation)
#              | archetype-id
#   name      := "'" ... "'" (a Locatable#name.value literal)
#
# Deliberately unsupported (raises InvalidPathError): relative paths,
# '//' wildcards, numeric index predicates, and general expression
# predicates. Those are layered on top by consumers (e.g. AQL); this
# class only parses the path shape used by RM path navigation.
#
# This file has no dependency on any RM class, so it can be required
# standalone.
module OpenEHR
  class Path
    class InvalidPathError < ArgumentError; end

    AT_CODE = /\Aat\d+(\.\d+)*\z/
    ARCHETYPE_ID = /\A[a-zA-Z]\w+-[a-zA-Z]\w+-[a-zA-Z]\w+\.[a-zA-Z]\w+(-[a-zA-Z]\w+)?\.v\d+\z/
    ATTRIBUTE = /\A[a-z][a-zA-Z0-9_]*\z/

    class Segment
      attr_reader :attribute, :archetype_node_id, :name

      def initialize(attribute, archetype_node_id: nil, name: nil)
        unless attribute.is_a?(String) && attribute =~ ATTRIBUTE
          raise InvalidPathError, "invalid path attribute: #{attribute.inspect}"
        end
        if archetype_node_id && !(archetype_node_id =~ AT_CODE || archetype_node_id =~ ARCHETYPE_ID)
          raise InvalidPathError, "invalid node id: #{archetype_node_id.inspect}"
        end
        raise InvalidPathError, 'name predicate requires a node_id predicate' if name && archetype_node_id.nil?

        @attribute = attribute
        @archetype_node_id = archetype_node_id
        @name = name
        freeze
      end

      def predicate?
        !@archetype_node_id.nil?
      end

      def to_s
        return @attribute unless predicate?

        s = "#{@attribute}[#{@archetype_node_id}"
        s += ", '#{@name}'" if @name
        s + ']'
      end

      def ==(other)
        other.is_a?(Segment) &&
          attribute == other.attribute &&
          archetype_node_id == other.archetype_node_id &&
          name == other.name
      end
      alias eql? ==

      def hash
        [attribute, archetype_node_id, name].hash
      end
    end

    def self.parse(str)
      raise InvalidPathError, 'path must be a String' unless str.is_a?(String)
      raise InvalidPathError, "path must start with '/': #{str.inspect}" unless str.start_with?('/')
      return new([]) if str == '/'

      body = str[1..-1]
      raise InvalidPathError, "path must not end with '/': #{str.inspect}" if body.end_with?('/')

      new(split_segments(body).map { |token| parse_segment(token) })
    end

    def self.valid?(str)
      parse(str)
      true
    rescue InvalidPathError
      false
    end

    # Splits on top-level '/' only (not '/' occurring inside a '[...]'
    # predicate), and rejects empty segments (i.e. a '//' wildcard).
    def self.split_segments(body)
      tokens = []
      depth = 0
      current = +''
      body.each_char do |c|
        case c
        when '['
          depth += 1
          current << c
        when ']'
          depth -= 1
          current << c
        when '/'
          if depth.zero?
            raise InvalidPathError, "empty path segment ('//' is not supported): #{body.inspect}" if current.empty?

            tokens << current
            current = +''
          else
            current << c
          end
        else
          current << c
        end
      end
      raise InvalidPathError, "unbalanced '[' in path: #{body.inspect}" unless depth.zero?
      raise InvalidPathError, "empty path segment ('//' is not supported): #{body.inspect}" if current.empty?

      tokens << current
      tokens
    end
    private_class_method :split_segments

    def self.parse_segment(token)
      if token =~ /\A([^\[\]]+)\[(.*)\]\z/
        attribute = Regexp.last_match(1)
        predicate = Regexp.last_match(2)
        if predicate =~ /\A([^,]+),\s*'([^']*)'\z/
          Segment.new(attribute, archetype_node_id: Regexp.last_match(1).strip, name: Regexp.last_match(2))
        else
          Segment.new(attribute, archetype_node_id: predicate.strip)
        end
      elsif token =~ /\A[^\[\]]+\z/
        Segment.new(token)
      else
        raise InvalidPathError, "malformed path segment: #{token.inspect}"
      end
    end
    private_class_method :parse_segment

    attr_reader :segments

    def initialize(segments)
      @segments = segments.freeze
      freeze
    end

    def root?
      @segments.empty?
    end

    def to_s
      return '/' if root?

      '/' + @segments.map(&:to_s).join('/')
    end

    def ==(other)
      other.is_a?(Path) && segments == other.segments
    end
    alias eql? ==

    def hash
      segments.hash
    end

    def parent
      return self if root?

      self.class.new(segments[0..-2])
    end

    def +(other)
      case other
      when Segment
        self.class.new(segments + [other])
      when Path
        self.class.new(segments + other.segments)
      when String
        self.class.new(segments + [Segment.new(other)])
      else
        raise ArgumentError, "cannot append #{other.class} to a Path"
      end
    end

    def descend
      return [nil, self] if root?

      [segments.first, self.class.new(segments[1..-1])]
    end
  end
end
