module OpenEHR
  module Parser
    module Scanner
      class Base
        attr_accessor :adl_type

        def initialize(filename)
          @filename = filename
        end

        def scan
          raise
        end
      end

      class ADLScanner < Base
        attr_accessor :adl_type, :cadl_scanner, :dadl_scanner, :regex_scanner, :term_constraint_scanner

        @@logger = OpenEHR::Parser::Scanner::LOGGER #Logger.new('log/scanner.log')
        RESERVED = {
          'archetype' => :SYM_ARCHETYPE,
          'adl_version' => :SYM_ADL_VERSION,
          'controlled' => :SYM_IS_CONTROLLED,
          'specialize' => :SYM_SPECIALIZE,
          'concept' => :SYM_CONCEPT,
          'language' => :SYM_LANGUAGE,
          'description' => :SYM_DESCRIPTION,
          'definition' => :SYM_DEFINITION,
          'invariant' => :SYM_INVARIANT,
          'ontology' => :SYM_ONTOLOGY,
          'matches' => :SYM_MATCHES,
          'is_in' => :SYM_MATCHES,
          'occurrences' => :SYM_OCCURRENCES,
          'true' => :SYM_TRUE, #[Tt][Rr][Uu][Ee] -- -> SYM_TRUE 
          'false' => :SYM_FALSE, # [Ff][Aa][Ll][Ss][Ee] -- -> SYM_FALSE 
          'infinity' => :SYM_INFINITY # [Ii][Nn][Ff][Ii][Nn][Ii][Tt][Yy] -- -> SYM_INFINITY 
        }
        REGEX_PATTERN = Hash[:CarriageReturn => /\A\n/,
                             :WhiteSpace => /\A[ \t\r\f]+/,
                             :SingleCommentLine => /\A--.*/,
                             :V_ISO8601_DURATION => /\AP([0-9]+[yY])?([0-9]+[mM])?([0-9]+[wW])?([0-9]+[dD])?T([0-9]+[hH])?([0-9]+[mM])?([0-9]+[sS])?|\AP([0-9]+[yY])?([0-9]+[mM])?([0-9]+[wW])?([0-9]+[dD])?/   #V_ISO8601_DURATION PnYnMnWnDTnnHnnMnnS
                            ]
        
        def initialize(filename)
          super(filename)
          @in_interval  = false
          data = File.read(fileName)
          @s = StringScanner.new(data)
        end

        #
        # ADLScanner#scan
        #
        def scan
          @@logger.debug("#{__FILE__}:#{__LINE__}: Entering  ADLScanner#scan at #{@filename}:#{@lineno}: data = #{data.inspect}")
          until @s.eos?  do
            case @adl_type.last
            when :adl
              case data
#              when /\A\n/ # carriage return
              when REGEX_PATTERN[:CarriageReturn] # carriage return
                @lineno += 1
                ;
#              when /\A[ \t\r\f]+/ #just drop it
              when REGEX_PATTERN[:WhiteSpace] # carriage return
                ;
#              when /\A--.*/ # single line comment
              when REGEX_PATTERN[:SingleCommentLine] # carriage return
                @lineno += 1
                @@logger.debug("ADLScanner#scan: COMMENT = #{$&} at #{@filename}:#{@lineno}")
                ;
              when /\Adescription/   # description
                yield :SYM_DESCRIPTION, :SYM_DESCRIPTION
              when /\Adefinition/   # definition
                yield :SYM_DEFINITION, :SYM_DEFINITION
              ###----------/* symbols */ ------------------------------------------------- 
              when /\A[A-Z][a-zA-Z0-9_]*/
                yield :V_TYPE_IDENTIFIER, $&
              when /\A(\w+)-(\w+)-(\w+)\.(\w+)((?:-\w+)*)\.(v\w+)/   #V_ARCHETYPE_ID
                object_id, rm_originator, rm_name, rm_entity, concept_name, specialisation, version_id = $&, $1, $2, $3, $4, $5, $6
                archetype_id = OpenEHR::RM::Support::Identification::ArchetypeID.new(:concept_name => concept_name, :rm_name => rm_name, :rm_entity => rm_entity, :rm_originator => rm_originator, :specialisation => specialisation, :version_id => version_id)
                yield :V_ARCHETYPE_ID, archetype_id
              when /\A[a-z][a-zA-Z0-9_]*/
                word = $&
                if RESERVED[word]
                  @@logger.debug("ADLScanner#scan: RESERVED = #{RESERVED[word]} at #{@filename}:#{@lineno}")
                  param = Array.new
                  param << RESERVED[word] << RESERVED[word]
#                  yield([[RESERVED[word], RESERVED[word]])
                  p param
                  yield param
                elsif #/\A[A-Z][a-zA-Z0-9_]*/
                  @@logger.debug("ADLScanner#scan: V_ATTRIBUTE_IDENTIFIER = #{$&} at #{@filename}:#{@lineno}")
                  yield :V_ATTRIBUTE_IDENTIFIER, $&
                end
              when /\A\=/   # =
                yield :SYM_EQ, :SYM_EQ
              when /\A\>=/   # >=
                yield :SYM_GE, :SYM_GE
              when /\A\<=/   # <=
                yield :SYM_LE, :SYM_LE
              when /\A\</   # <
                if @in_interval
                  yield :SYM_LT, :SYM_LT
                else
                  @adl_type.push(:dadl)
                  yield :SYM_START_DBLOCK,  $&
                end
              when /\A\>/   # >
                if @in_interval
                  yield :SYM_GT, :SYM_GT
                else
                  adl_type = @adl_type.pop
                  assert_at(__FILE__,__LINE__){adl_type == :dadl}
                  yield :SYM_END_DBLOCK, :SYM_END_DBLOCK
                end
              when /\A\{/   # {
                @adl_type.push(:cadl)
                @@logger.debug("ADLScanner#scan: SYM_START_CBLOCK")
                yield :SYM_START_CBLOCK, :SYM_START_CBLOCK
              when /\A\}/   # }
                adl_type = @adl_type.pop
                assert_at(__FILE__,__LINE__){adl_type == :cadl}
                @@logger.debug("ADLScanner#scan: SYM_END_CBLOCK")
                yield :SYM_END_CBLOCK, $&
              when /\A\-/   # -
                yield :Minus_code, :Minus_code
              when /\A\+/   # +
                yield :Plus_code, :Plus_code
              when /\A\*/   # *
                yield :Star_code, :Star_code
              when /\A\//   # /
                yield :Slash_code, :Slash_code
              when /\A\^/   # ^
                yield :Caret_code, :Caret_code
              when /\A\=/   # =
                yield :Equal_code, :Equal_code
              when /\A\.\.\./   # ...
                yield :SYM_LIST_CONTINUE, :SYM_LIST_CONTINUE
              when /\A\.\./   # ..
                yield :SYM_ELLIPSIS, :SYM_ELLIPSIS
              when /\A\./   # .
                yield :Dot_code, :Dot_code
              when /\A\;/   # ;
                yield :Semicolon_code, :Semicolon_code
              when /\A\,/   # ,
                yield :Comma_code, :Comma_code
              when /\A\:/   # :
                yield :Colon_code, :Colon_code
              when /\A\!/   # !
                yield :Exclamation_code, :Exclamation_code
              when /\A\(/   # (
                yield :Left_parenthesis_code, :Left_parenthesis_code
              when /\A\)/   # )
                yield :Right_parenthesis_code, :Right_parenthesis_code
              when /\A\$/   # $
                yield :Dollar_code, :Dollar_code
              when /\A\?\?/   # ??
                yield :SYM_DT_UNKNOWN, :SYM_DT_UNKNOWN
              when /\A\?/   # ?
                yield :Question_mark_code, :Question_mark_code
              when /\A[0-9]+\.[0-9]+(\.[0-9]+)*/   # ?
                yield :V_VERSION_STRING, $&
              when /\A\|/   # |
                if @in_interval
                  @in_interval = false
                else
                  @in_interval = true
                end
                yield :SYM_INTERVAL_DELIM, :SYM_INTERVAL_DELIM
              when /\A\[([a-zA-Z0-9()\._-]+::[a-zA-Z0-9\._-]+)\]/ #V_QUALIFIED_TERM_CODE_REF form such as [ICD10AM(1998)::F23]
                yield :V_QUALIFIED_TERM_CODE_REF, $1
              when /\A\[([a-zA-Z0-9][a-zA-Z0-9._\-]*)\]/   #V_LOCAL_TERM_CODE_REF
                yield :V_LOCAL_TERM_CODE_REF, $1
              when /\A\[/   # [
                yield :Left_bracket_code, :Left_bracket_code
              when /\A\]/   # ]
                yield :Right_bracket_code, :Right_bracket_code
              when /\A"([^"]*)"/m #V_STRING
                yield :V_STRING, $1
              when /\A\[[a-zA-Z0-9._\- ]+::[a-zA-Z0-9._\- ]+\]/   #ERR_V_QUALIFIED_TERM_CODE_REF
                yield :ERR_V_QUALIFIED_TERM_CODE_REF, $&
              when /\Aa[ct][0-9.]+/   #V_LOCAL_CODE
                yield :V_LOCAL_CODE, $&
              when /\A[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9](,[0-9]+)?(Z|[+-][0-9]{4})?|[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9](Z|[+-][0-9]{4})?|[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9](Z|[+-][0-9]{4})?/   #V_ISO8601_EXTENDED_DATE_TIME YYYY-MM-DDThh:mm:ss[,sss][Z|+/- -n-n-n-n-]-
                yield :V_ISO8601_EXTENDED_DATE_TIME, $&
              when /\A[0-2][0-9]:[0-6][0-9]:[0-6][0-9](,[0-9]+)?(Z|[+-][0-9]{4})?|[0-2][0-9]:[0-6][0-9](Z|[+-][0-9]{4})? /   #V_ISO8601_EXTENDED_TIME hh:mm:ss[,sss][Z|+/-nnnn]
                yield :V_ISO8601_EXTENDED_TIME, $&
              when /\A[0-9]{4}-[0-1][0-9]-[0-3][0-9]|[0-9]{4}-[0-1][0-9]/   #V_ISO8601_EXTENDED_DATE YYYY-MM-DD
                yield :V_ISO8601_EXTENDED_DATE, $&
              when /\A[A-Z][a-zA-Z0-9_]*<[a-zA-Z0-9,_<>]+>/   #V_GENERIC_TYPE_IDENTIFIER
                yield :V_GENERIC_TYPE_IDENTIFIER, $&
              when /\A[0-9]+|[0-9]+[eE][+-]?[0-9]+/   #V_INTEGER
                @@logger.debug("ADLScanner#scan: V_INTEGER = #{$&}")
                yield :V_INTEGER, $&
              when /\A[0-9]+\.[0-9]+|[0-9]+\.[0-9]+[eE][+-]?[0-9]+ /   #V_REAL
                yield :V_REAL, $&
                #    when /\A"((?:[^"\\]+|\\.)*)"/ #V_STRING
              when /\A[a-z]+:\/\/[^<>|\\{}^~"\[\] ]*/ #V_URI
                yield :V_URI, $&
              when /\AP([0-9]+[yY])?([0-9]+[mM])?([0-9]+[wW])?([0-9]+[dD])?T([0-9]+[hH])?([0-9]+[mM])?([0-9]+[sS])?/   #V_ISO8601_DURATION PnYnMnWnDTnnHnnMnnS
                yield :V_ISO8601_DURATION, $&
              when /\AP([0-9]+[yY])?([0-9]+[mM])?([0-9]+[wW])?([0-9]+[dD])?/   #V_ISO8601_DURATION PnYnMnWnDTnnHnnMnnS
                yield :V_ISO8601_DURATION, $&
              when /\A\S/ #UTF8CHAR
                yield :UTF8CHAR, $&
              end
              data = $' # variable $' receives the string after the match
            when :dadl
              dadl_scanner = OpenEHR::Parser::Scanner::DADLScanner.new(@adl_type, @filename, @lineno)
              data = dadl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :cadl
              cadl_scanner = OpenEHR::Parser::Scanner::CADLScanner.new(@adl_type, @filename, @lineno)
              data = cadl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :regexp
              regex_scanner = OpenEHR::Parser::Scanner::RegexScanner.new(@adl_type, @filename, @lineno)
              data = regex_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :term_constraint
              term_constraint_scanner = OpenEHR::Parser::Scanner::TermConstraintScanner.new(@adl_type, @filename, @lineno)
              data = term_constraint_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            else
              raise
            end
          end
        end
      end # of ADLScanner

      
      # DADLScanner
      # 
      class DADLScanner < ADLScanner
        attr_accessor :in_interval, :in_c_domain_type, :dblock_depth
        @@logger = OpenEHR::Parser::Scanner::LOGGER #Logger.new('log/scanner.log')
        RESERVED = {
          'true' => :SYM_TRUE, #[Tt][Rr][Uu][Ee] -- -> SYM_TRUE 
          'false' => :SYM_FALSE, # [Ff][Aa][Ll][Ss][Ee] -- -> SYM_FALSE 
          'infinity' => :SYM_INFINITY # [Ii][Nn][Ff][Ii][Nn][Ii][Tt][Yy] -- -> SYM_INFINITY 
        }

        def initialize(adl_type, filename, lineno = 1)
          super(adl_type, filename, lineno)
          @in_interval = false
          @in_c_domain_type = false
          @dblock_depth = 0
        end

        #
        # DADLScanner#scan
        #
        def scan(data)
          @@logger.debug("Entering DADLScanner#scan at #{@filename}:#{@lineno}: @adl_type = #{@adl_type.inspect}, data = #{data.inspect}")
          until data.nil?  do
            @@logger.debug("#{@filename}:#{@lineno}: DADLScanner#scan:loop data = #{data.inspect}")
            @@logger.debug("#{@filename}:#{@lineno}: DADLScanner#scan:loop self = \n#{self.to_yaml}")
            case @adl_type.last
            when :dadl
              case data
#              when /\A\n/ # carriage return
              when REGEX_PATTERN[:CarriageReturn] # carriage return
                @lineno += 1
                ;
#              when /\A[ \t\r\f]+/ #just drop it
              when REGEX_PATTERN[:WhiteSpace]
                ##@@logger.debug("DADLScanner#scan:  white space, data = #{data.inspect}")
                ;
#              when /\A--.*/ # single line comment
              when REGEX_PATTERN[:SingleCommentLine]
                @@logger.debug("DADLScanner#scan: COMMENT = #{$&} at #{@filename}:#{@lineno}")
                ;
              when /\A[a-z]+:\/\/[^<>|\\{}^~"\[\] ]*/ #V_URI
                yield :V_URI, $&
              when /\A[a-z][a-zA-Z0-9_]*/
                word = $&.dup
                if RESERVED[word.downcase]
                  yield RESERVED[word.downcase], RESERVED[word.downcase]
                else
                  @@logger.debug("DADLScanner#scan: V_ATTRIBUTE_IDENTIFIER = #{word} at #{@filename}:#{@lineno}")
                  yield :V_ATTRIBUTE_IDENTIFIER, word #V_ATTRIBUTE_IDENTIFIER /\A[a-z][a-zA-Z0-9_]*/
                end
                ###----------/* symbols */ ------------------------------------------------- 
              when /\A\=/   # =
                yield :SYM_EQ, :SYM_EQ
              when /\A\>\=/   # >=
                yield :SYM_GE, :SYM_GE
              when /\A\<\=/   # <=
                yield :SYM_LE, :SYM_LE
              when /\A\</   # <
                if @in_interval
                  yield :SYM_LT, :SYM_LT
                else
                  unless @in_c_domain_type
                    @adl_type.push(:dadl)
                  else
                    @dblock_depth += 1
                  end
                  yield :SYM_START_DBLOCK, :SYM_START_DBLOCK
                end
              when /\A\>/   # >
                if @in_interval
                  yield :SYM_GT, :SYM_GT
                else
                  if @in_c_domain_type
                    assert_at(__FILE__,__LINE__){@adl_type.last == :dadl}
                    @dblock_depth -= 1
                    if @dblock_depth < 0
                      @adl_type.pop
                      @in_c_domain_type = false
                      yield :END_V_C_DOMAIN_TYPE_BLOCK, :END_V_C_DOMAIN_TYPE_BLOCK
                    else
                      yield :SYM_END_DBLOCK, :SYM_END_DBLOCK
                    end
                  else
                    adl_type = @adl_type.pop
                    assert_at(__FILE__,__LINE__){adl_type == :dadl}
                    yield :SYM_END_DBLOCK, $&
                  end
                end
              when /\A\-/   # -
                yield :Minus_code, :Minus_code
              when /\A\+/   # +
                yield :Plus_code, :Plus_code
              when /\A\*/   # *
                yield :Star_code, :Star_code
              when /\A\//   # /
                yield :Slash_code, :Slash_code
              when /\A\^/   # ^
                yield :Caret_code, :Caret_code
              when /\A\.\.\./   # ...
                yield :SYM_LIST_CONTINUE, :SYM_LIST_CONTINUE
              when /\A\.\./   # ..
                yield :SYM_ELLIPSIS, :SYM_ELLIPSIS
              when /\A\./   # .
                yield :Dot_code, :Dot_code
              when /\A\;/   # ;
                yield :Semicolon_code, :Semicolon_code
              when /\A\,/   # ,
                @@logger.debug("DADLScanner#scan: Comma_code")
                yield :Comma_code, :Comma_code
              when /\A\:/   # :
                yield :Colon_code, :Colon_code
              when /\A\!/   # !
                yield :Exclamation_code, :Exclamation_code
              when /\A\(/   # (
                yield :Left_parenthesis_code, :Left_parenthesis_code
              when /\A\)/   # )
                yield :Right_parenthesis_code, :Right_parenthesis_code
              when /\A\$/   # $
                yield :Dollar_code, :Dollar_code
              when /\A\?\?/   # ??
                yield :SYM_DT_UNKNOWN, :SYM_DT_UNKNOWN
              when /\A\?/   # ?
                yield :Question_mark_code, :Question_mark_code
              when /\A\|/   # |
                @@logger.debug("DADLScanner#scan: @in_interval = #{@in_interval} at #{@filename}:#{@lineno}")
                if @in_interval
                  @in_interval = false
                else
                  @in_interval = true
                end
                @@logger.debug("DADLScanner#scan: SYM_INTERVAL_DELIM at #{@filename}:#{@lineno}")
                yield :SYM_INTERVAL_DELIM, :SYM_INTERVAL_DELIM
              when /\A\[([a-zA-Z0-9()\._-]+::[a-zA-Z0-9\._-]+)\]/  #V_QUALIFIED_TERM_CODE_REF form [ICD10AM(1998)::F23]
                yield :V_QUALIFIED_TERM_CODE_REF, $1
              when /\A\[/   # [
                @@logger.debug("DADLScanner#scan: Left_bracket_code at #{@filename}:#{@lineno}")
                yield :Left_bracket_code, :Left_bracket_code
              when /\A\]/   # ]
                @@logger.debug("DADLScanner#scan: Right_bracket_code at #{@filename}:#{@lineno}")
                yield :Right_bracket_code, :Right_bracket_code
              when /\A"((?:[^"\\]+|\\.)*)"/ #V_STRING
                @@logger.debug("DADLScanner#scan: V_STRING, #{$1}")
                yield :V_STRING, $1
              when /\A"([^"]*)"/m #V_STRING
                @@logger.debug("DADLScanner#scan: V_STRING, #{$1}")
                yield :V_STRING, $1
              when /\A[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9](,[0-9]+)?(Z|[+-][0-9]{4})?|[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9](Z|[+-][0-9]{4})?|[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9](Z|[+-][0-9]{4})?/   #V_ISO8601_EXTENDED_DATE_TIME YYYY-MM-DDThh:mm:ss[,sss][Z|+/- -n-n-n-n-]-
                @@logger.debug("DADLScanner#scan: V_ISO8601_EXTENDED_DATE_TIME")
                yield :V_ISO8601_EXTENDED_DATE_TIME, $&
              when /\A[0-2][0-9]:[0-6][0-9]:[0-6][0-9](,[0-9]+)?(Z|[+-][0-9]{4})?|[0-2][0-9]:[0-6][0-9](Z|[+-][0-9]{4})? /   #V_ISO8601_EXTENDED_TIME hh:mm:ss[,sss][Z|+/-nnnn]
                @@logger.debug("DADLScanner#scan: V_ISO8601_EXTENDED_TIME")
                yield :V_ISO8601_EXTENDED_TIME, $&
              when /\A\d{4}-[0-1][0-9]-[0-3][0-9]|[0-9]{4}-[0-1][0-9]/   #V_ISO8601_EXTENDED_DATE YYYY-MM-DD
                @@logger.debug("DADLScanner#scan: V_ISO8601_EXTENDED_DATE, #{$&}")
                yield :V_ISO8601_EXTENDED_DATE, $&
              when /\A[A-Z][a-zA-Z0-9_]*<[a-zA-Z0-9,_<>]+>/   #V_GENERIC_TYPE_IDENTIFIER
                yield :V_GENERIC_TYPE_IDENTIFIER, $&
              when /\A[0-9]+\.[0-9]+|[0-9]+\.[0-9]+[eE][+-]?[0-9]+ /   #V_REAL
                yield :V_REAL, $&
              when /\A[0-9]+|[0-9]+[eE][+-]?[0-9]+/   #V_INTEGER
                @@logger.debug("DADLScanner#scan: V_INTEGER = #{$&}")
                yield :V_INTEGER, $&
              when /\A\S/ #UTF8CHAR
                yield :UTF8CHAR, $&
              end
              data = $' # variable $' receives the string after the match
            when :adl
              adl_scanner = OpenEHR::Parser::Scanner::ADLScanner.new(@adl_type, @filename, @lineno)
              data = adl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :cadl
              cadl_scanner = OpenEHR::Parser::Scanner::CADLScanner.new(@adl_type, @filename, @lineno)
              data = cadl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :regexp
              regex_scanner = OpenEHR::Parser::Scanner::RegexScanner.new(@adl_type, @filename, @lineno)
              data = regex_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :term_constraint
              @@logger.debug("#{__FILE__}:#{__LINE__}: scan_dadl: Entering scan_term_constraint at #{@filename}:#{@lineno}: data = #{data.inspect}")
              term_constraint_scanner = OpenEHR::Parser::Scanner::TermConstraintScanner.new(@adl_type, @filename, @lineno)
              data = term_constraint_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            else
              raise
            end
          end
        end
      end # of DADLScanner

      class CADLScanner < ADLScanner

        @@logger = OpenEHR::Parser::Scanner::LOGGER #Logger.new('log/scanner.log')        #Logger.new('log/scanner.log')
        RESERVED = {
          'then' => :SYM_THEN, # [Tt][Hh][Ee][Nn]
          'else' => :SYM_ELSE, # [Ee][Ll][Ss][Ee]
          'and' => :SYM_AND, # [Aa][Nn][Dd]
          'or' => :SYM_OR, # [Oo][Rr]
          'xor' => :SYM_XOR, # [Xx][Oo][Rr]
          'not' => :SYM_NOT, # [Nn][Oo][Tt]
          'implies' => :SYM_IMPLIES, # [Ii][Mm][Pp][Ll][Ii][Ee][Ss]
          'true' => :SYM_TRUE, #[Tt][Rr][Uu][Ee] -- -> SYM_TRUE 
          'false' => :SYM_FALSE, # [Ff][Aa][Ll][Ss][Ee] -- -> SYM_FALSE 
          'forall' => :SYM_FORALL, # [Ff][Oo][Rr][_][Aa][Ll][Ll]
          'exists' => :SYM_EXISTS, # [Ee][Xx][Ii][Ss][Tt][Ss]
          'existence' => :SYM_EXISTENCE, # [Ee][Xx][Iu][Ss][Tt][Ee][Nn][Cc][Ee]
          'occurrences' => :SYM_OCCURRENCES, # [Oo][Cc][Cc][Uu][Rr][Rr][Ee][Nn][Cc][Ee][Ss]
          'cardinality' => :SYM_CARDINALITY, # [Cc][Aa][Rr][Dd][Ii][Nn][Aa][Ll][Ii][Tt][Yy]
          'ordered' => :SYM_ORDERED, # [Oo][Rr][Dd][Ee][Rr][Ee][Dd]
          'unordered' => :SYM_UNORDERED, # [Uu][Nn][Oo][Rr][Dd][Ee][Rr][Ee][Dd]
          'unique' => :SYM_UNIQUE, # [Uu][Nn][Ii][Qq][Uu][Ee]
          'matches' => :SYM_MATCHES, # [Mm][Aa][Tt][Cc][Hh][Ee][Ss]
          'is_in' => :SYM_MATCHES, # [Ii][Ss][_][Ii][Nn]
          'invariant' => :SYM_INVARIANT, # [Ii][Nn][Vv][Aa][Rr][Ii][Aa][Nn][Tt]
          'infinity' => :SYM_INFINITY, # [Ii][Nn][Ff][Ii][Nn][Ii][Tt][Yy] -- -> SYM_INFINITY 
          'use_node' => :SYM_USE_NODE, # [Uu][Ss][Ee][_][Nn][Oo][Dd][Ee]
          'use_archetype' => :SYM_ALLOW_ARCHETYPE, # [Uu][Ss][Ee][_][Aa][Rr][Cc][Hh][Ee][Tt][Yy][Pp][Ee]
          'allow_archetype' => :SYM_ALLOW_ARCHETYPE, # [Aa][Ll][Ll][Oo][Ww][_][Aa][Rr][Cc][Hh][Ee][Tt][Yy][Pp][Ee]
          'include' => :SYM_INCLUDE, # [Ii][Nn][Cc][Ll][Uu][Dd][Ee]
          'exclude' => :SYM_EXCLUDE # [Ee][Xx][Cc][Ll][Uu][Dd][Ee]
        }

        def initialize(adl_type, filename, lineno = 1)
          super(adl_type, filename, lineno)
          @in_interval = false
        end

        #
        # CADLScanner#scan
        #
        def scan(data)
          @@logger.debug("#{__FILE__}:#{__LINE__}: Entering CADLScanner#scan at #{@filename}:#{@lineno}: data = #{data.inspect}")
          until data.nil?  do
            @@logger.debug("CADLScanner#scan:  loop data = #{data.inspect}")
            case @adl_type.last
            when :cadl
              case data
#              when /\A\n/ # carriage return
              when REGEX_PATTERN[:CarriageReturn] # carriage return
                @lineno += 1
                ;
                #yield :CR, :CR
#              when /\A[ \t\r\f]+/ #just drop it
              when REGEX_PATTERN[:WhiteSpace]
                ;
#              when /\A--.*\n/ # single line comment
              when REGEX_PATTERN[:SingleCommentLine]
                @lineno += 1
                ;
              ###----------/* symbols */ ------------------------------------------------- 
              when /\A\=/   # =
                yield :SYM_EQ, :SYM_EQ
              when /\A\>=/   # >=
                yield :SYM_GE, :SYM_GE
              when /\A\<=/   # <=
                yield :SYM_LE, :SYM_LE
              when /\A\</   # <
                if @in_interval
                  yield :SYM_LT, :SYM_LT
                else
                  @adl_type.push(:dadl)
                  yield :SYM_START_DBLOCK,  $&
                end
              when /\A\>/   # >
                if @in_interval
                  yield :SYM_GT, :SYM_GT
                else
                  adl_type = @adl_type.pop
                  assert_at(__FILE__,__LINE__){adl_type == :dadl}
                  yield :SYM_END_DBLOCK, :SYM_END_DBLOCK
                end
              when /\A\-/   # -
                yield :Minus_code, :Minus_code
              when /\A\+/   # +
                yield :Plus_code, :Plus_code
              when /\A\=/   # =
                yield :Equal_code, :Equal_code
              when /\A\*/   # *
                yield :Star_code, :Star_code
              when /\A\^/   # ^
                yield :Caret_code, :Caret_code
              when /\A\.\.\./   # ...
                yield :SYM_LIST_CONTINUE, :SYM_LIST_CONTINUE
              when /\A\.\./   # ..
                yield :SYM_ELLIPSIS, :SYM_ELLIPSIS
              when /\A\./   # .
                yield :Dot_code, :Dot_code
              when /\A\;/   # ;
                yield :Semicolon_code, :Semicolon_code
              when /\A\,/   # ,
                yield :Comma_code, :Comma_code
              when /\A\:/   # :
                yield :Colon_code, :Colon_code
              when /\A\!/   # !
                yield :Exclamation_code, :Exclamation_code
              when /\A\(/   # (
                yield :Left_parenthesis_code, :Left_parenthesis_code
              when /\A\)/   # )
                yield :Right_parenthesis_code, :Right_parenthesis_code
              when /\A\//   # /
                @@logger.debug("CADLScanner#scan: Slash_code #{@filename}:#{@lineno}")
                yield :Slash_code, :Slash_code
              when /\A\{\// # REGEXP_HEAD {/
                assert_at(__FILE__,__LINE__){ @adl_type.last != :regexp}
                #                   @in_regexp = true
                @@logger.debug("CADLScanner#scan: REGEXP_HEAD:")
                @adl_type.push(:cadl)
                @adl_type.push(:regexp)
                #                   yield :START_REGEXP_BLOCK, :START_REGEXP_BLOCK
                yield :REGEXP_HEAD, :REGEXP_HEAD
              when /\A\{/   # {
                @adl_type.push(:cadl)
                #@@logger.debug("CADLScanner#scan: entering cADL at #{@filename}:#{@lineno}")
                yield :SYM_START_CBLOCK, :SYM_START_CBLOCK
              when /\A\}/   # }
                adl_type = @adl_type.pop
                assert_at(__FILE__,__LINE__){adl_type == :cadl}
                @@logger.debug("CADLScanner#scan: exiting cADL at #{@filename}:#{@lineno}")
                yield :SYM_END_CBLOCK, :SYM_END_CBLOCK
              when /\A\$/   # $
                yield :Dollar_code, :Dollar_code
              when /\A\?\?/   # ??
                yield :SYM_DT_UNKNOWN, :SYM_DT_UNKNOWN
              when /\A\?/   # ?
                yield :Question_mark_code, :Question_mark_code
              when /\A\|/   # |
                if @in_interval
                  @in_interval = false
                else
                  @in_interval = true
                end
                @@logger.debug("CADLScanner#scan: @in_interval = #{@in_interval} at #{@filename}:#{@lineno}")
                @@logger.debug("CADLScanner#scan: SYM_INTERVAL_DELIM at #{@filename}:#{@lineno}")
                yield :SYM_INTERVAL_DELIM, :SYM_INTERVAL_DELIM

              when /\A\[([a-zA-Z0-9()\._-]+::[a-zA-Z0-9\._-]+)\]/  #V_QUALIFIED_TERM_CODE_REF form [ICD10AM(1998)::F23]
                yield :V_QUALIFIED_TERM_CODE_REF, $1
              when /\A\[[a-zA-Z0-9._\- ]+::[a-zA-Z0-9._\- ]+\]/   #ERR_V_QUALIFIED_TERM_CODE_REF
                yield :ERR_V_QUALIFIED_TERM_CODE_REF, $&
              when /\A\[([a-zA-Z0-9\(\)\._\-]+)::[ \t\n]*/
                @adl_type.push(:term_constraint)
                yield :START_TERM_CODE_CONSTRAINT, $1
              when /\A\[([a-zA-Z0-9][a-zA-Z0-9._\-]*)\]/   #V_LOCAL_TERM_CODE_REF
                yield :V_LOCAL_TERM_CODE_REF, $1
              when /\A\[/   # [
                yield :Left_bracket_code, :Left_bracket_code
              when /\A\]/   # ]
                yield :Right_bracket_code, :Right_bracket_code
              when /\A[A-Z][a-zA-Z0-9_]*<[a-zA-Z0-9,_<>]+>/   #V_GENERIC_TYPE_IDENTIFIER
                yield :V_GENERIC_TYPE_IDENTIFIER, $&
              when /\A[yY][yY][yY][yY]-[mM?X][mM?X]-[dD?X][dD?X][Tt][hH?X][hH?X]:[mM?X][mM?X]:[sS?X][sS?X]/
                yield :V_ISO8601_DATE_TIME_CONSTRAINT_PATTERN, $&
              when /\A[yY][yY][yY][yY]-[mM?X][mM?X]-[dD?X][dD?X]/
                yield :V_ISO8601_DATE_CONSTRAINT_PATTERN, $&
              when /\A[hH][hH]:[mM?X][mM?X]:[sS?X][sS?X]/
                yield :V_ISO8601_TIME_CONSTRAINT_PATTERN, $&
              when /\AP[yY]?[mM]?[wW]?[dD]?T[hH]?[mM]?[sS]?/   #V_ISO8601_DURATION_CONSTRAINT_PATTERN
                if $&.length == 2
                  case data
                  when /\AP([0-9]+[yY])?([0-9]+[mM])?([0-9]+[wW])?([0-9]+[dD])?T([0-9]+[hH])?([0-9]+[mM])?([0-9.]+[sS])?/   #V_ISO8601_DURATION PnYnMnWnDTnnHnnMnnS
                    yield :V_ISO8601_DURATION, $&
                  else
                    yield :V_ISO8601_DURATION_CONSTRAINT_PATTERN, $&
                  end
                else
                  yield :V_ISO8601_DURATION_CONSTRAINT_PATTERN, $&
                end
              when /\AP[yY]?[mM]?[wW]?[dD]?/   #V_ISO8601_DURATION_CONSTRAINT_PATTERN
                if $&.length == 1
                  case data
                  when /\AP([0-9]+[yY])?([0-9]+[mM])?([0-9]+[wW])?([0-9]+[dD])?/   #V_ISO8601_DURATION PnYnMnWnDTnnHnnMnnS
                    yield :V_ISO8601_DURATION, $&
                  else
                    yield :V_ISO8601_DURATION_CONSTRAINT_PATTERN, $&
                  end
                else
                  yield :V_ISO8601_DURATION_CONSTRAINT_PATTERN, $&
                end
              when /\AP[yY]?[mM]?[wW]?[dD]?/   #V_ISO8601_DURATION_CONSTRAINT_PATTERN
                yield :V_ISO8601_DURATION_CONSTRAINT_PATTERN, $&
              when /\A[a-z][a-zA-Z0-9_]*/
                word = $&.dup
                if RESERVED[word.downcase]
                  @@logger.debug("ADLScanner#scan: RESERVED = #{RESERVED[word]} at #{@filename}:#{@lineno}")
                  yield RESERVED[word.downcase], RESERVED[word.downcase]
                else
                  @@logger.debug("CADLScanner#scan: V_ATTRIBUTE_IDENTIFIER = #{word} at #{@filename}:#{@lineno}")
                  yield :V_ATTRIBUTE_IDENTIFIER, word #V_ATTRIBUTE_IDENTIFIER /\A[a-z][a-zA-Z0-9_]*/
                end
              when /\A([A-Z][a-zA-Z0-9_]*)[ \n]*\</ # V_C_DOMAIN_TYPE
                @in_c_domain_type = true
                @adl_type.push(:dadl)
                yield  :START_V_C_DOMAIN_TYPE_BLOCK, $1
              when /\A[A-Z][a-zA-Z0-9_]*/
                word = $&.dup
                if RESERVED[word.downcase]
                  yield RESERVED[word.downcase], RESERVED[word.downcase]
                else
                  yield :V_TYPE_IDENTIFIER, $&
                end
              when /\Aa[ct][0-9.]+/   #V_LOCAL_CODE
                yield :V_LOCAL_CODE, $&
              when /\A[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9](,[0-9]+)?(Z|[+-][0-9]{4})?/    #V_ISO8601_EXTENDED_DATE_TIME YYYY-MM-DDThh:mm:ss[,sss][Z|+/- -n-n-n-n-]-
                yield :V_ISO8601_EXTENDED_DATE_TIME, $&
              when /\A[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9](Z|[+-][0-9]{4})?/
                yield :V_ISO8601_EXTENDED_DATE_TIME, $&
              when /\A[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9](Z|[+-][0-9]{4})?/
                yield :V_ISO8601_EXTENDED_DATE_TIME, $&
              when /\A[0-2][0-9]:[0-6][0-9]:[0-6][0-9](,[0-9]+)?(Z|[+-][0-9]{4})?/   #V_ISO8601_EXTENDED_TIME hh:mm:ss[,sss][Z|+/-nnnn]
                yield :V_ISO8601_EXTENDED_TIME, $&
              when /\A[0-2][0-9]:[0-6][0-9](Z|[+-][0-9]{4})?/   #V_ISO8601_EXTENDED_TIME hh:mm:ss[,sss][Z|+/-nnnn]
                yield :V_ISO8601_EXTENDED_TIME, $&
              when /\A[0-9]{4}-[0-1][0-9]-[0-3][0-9]/   #V_ISO8601_EXTENDED_DATE YYYY-MM-DD
                yield :V_ISO8601_EXTENDED_DATE, $&
              when /\A[0-9]{4}-[0-1][0-9]/   #V_ISO8601_EXTENDED_DATE YYYY-MM-DD
                yield :V_ISO8601_EXTENDED_DATE, $&
              when /\A"((?:[^"\\]+|\\.)*)"/ #V_STRING
                yield :V_STRING, $1
              when /\A"([^"]*)"/m #V_STRING
                yield :V_STRING, $1
              when /\A[0-9]+\.[0-9]+|[0-9]+\.[0-9]+[eE][+-]?[0-9]+ /   #V_REAL
                yield :V_REAL, $&
              when /\A[0-9]+|[0-9]+[eE][+-]?[0-9]+/   #V_INTEGER
                @@logger.debug("CADLScanner#scan: V_INTEGER = #{$&}")
                yield :V_INTEGER, $&
              when /\A[a-z]+:\/\/[^<>|\\{}^~"\[\] ]*/ #V_URI
                yield :V_URI, $&
              when /\A\S/ #UTF8CHAR
                yield :UTF8CHAR, $&
              when /\A.+/ #
                raise OpenEHR::Parser::Exception::CADLScanner::Base.new, "can't handle #{data.inspect}"
              end
              data = $' # variable $' receives the string after the match
            when :adl
              adl_scanner = OpenEHR::Parser::Scanner::ADLScanner.new(@adl_type, @filename, @lineno)
              data = adl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :dadl
              dadl_scanner = OpenEHR::Parser::Scanner::DADLScanner.new(@adl_type, @filename, @lineno)
              dadl_scanner.in_c_domain_type = @in_c_domain_type
              data = dadl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :regexp
              regex_scanner = OpenEHR::Parser::Scanner::RegexScanner.new(@adl_type, @filename, @lineno)
              data = regex_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :term_constraint
              term_constraint_scanner = OpenEHR::Parser::Scanner::TermConstraintScanner.new(@adl_type, @filename, @lineno)
              data = term_constraint_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            else
              raise OpenEHR::Parser::Exception::CADLScanner.new, "unexpected adl_type: #{@adl_type.last}"
            end
          end # of until
        end
      end # of CADLScanner


      #
      # RegexScanner
      # 
      class RegexScanner < Base

        @@logger = OpenEHR::Parser::Scanner::LOGGER #Logger.new('log/scanner.log')        #Logger.new('log/scanner.log')
        
        def initialize(adl_type, filename, lineno = 1)
          super(adl_type, filename, lineno)
        end

        def scan(data)
          @@logger.debug("#{__FILE__}:#{__LINE__}: Entering RegexScanner::scan at #{@filename}:#{@lineno}: data = #{data.inspect}")
          until data.nil?  do
            case @adl_type.last
            when :regexp
              case data
              when /\A(.*)\// # REGEXP_BODY
                @adl_type.pop
                @@logger.debug("#{__FILE__}:#{__LINE__}: RegexScanner::scan REGEXP_BODY = #{$1}")
                yield :REGEXP_BODY, $1
              end
              data = $' # variable $' receives the string after the match
            when :adl
              adl_scanner = OpenEHR::Parser::Scanner::ADLScanner.new(@adl_type, @filename, @lineno)
              data = adl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :dadl
              dadl_scanner = OpenEHR::Parser::Scanner::DADLScanner.new(@adl_type, @filename, @lineno)
              data = dadl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :cadl
              cadl_scanner = OpenEHR::Parser::Scanner::CADLScanner.new(@adl_type, @filename, @lineno)
              data = cadl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :term_constraint
              #@@logger.debug("#{__FILE__}:#{__LINE__}: scan_regexp: Entering scan_term_constraint at #{@filename}:#{@lineno}")
              term_constraint_scanner = OpenEHR::Parser::Scanner::TermConstraintScanner.new(@adl_type, @filename, @lineno)
              data = term_constraint_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            else
              raise 
            end
          end
        end
      end # of RegexScanner

      #
      # TermConstraintScanner
      # 
      class TermConstraintScanner < Base
        @@logger = OpenEHR::Parser::Scanner::LOGGER #Logger.new('log/scanner.log')        #Logger.new('log/scanner.log')
        def initialize(adl_type, filename, lineno = 1)
          super(adl_type, filename, lineno)
        end

        def scan(data)
          @@logger.debug("#{__FILE__}:#{__LINE__}: Entering scan_term_constraint")
          until data.nil?  do
            case @adl_type.last
            when :term_constraint
              case data
              when /\A\n/ # carriage return
                @lineno += 1
                ;
              when /\A[ \t\r\f]+/ #just drop it
                ;
              when /\A--.*$/ # single line comment
                @lineno += 1
                @@logger.debug("#{__FILE__}:#{__LINE__}: scan_term_constraint: COMMENT = #{$&} at #{@filename}:#{@lineno}")
                ;
              when /\A([a-zA-Z0-9\._\-])+[ \t]*,/ # match any line, with ',' termination
                yield :TERM_CODE, $1
              when /\A([a-zA-Z0-9\._\-])+[ \t]*;/ # match second last line with ';' termination (assumed value)
                yield :TERM_CODE, $1
              when /\A([a-zA-Z0-9\._\-])*[ \t]*\]/ # match final line, terminating in ']'
                adl_type = @adl_type.pop
                assert_at(__FILE__,__LINE__){adl_type == :term_constraint}
                yield :END_TERM_CODE_CONSTRAINT, $1
#               else
#                 raise "data = #{data}"
              end
              data = $' # variable $' receives the string after the match
            when :adl
              adl_scanner = OpenEHR::Parser::Scanner::ADLScanner.new(@adl_type, @filename, @lineno)
              data = adl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :dadl
              dadl_scanner = OpenEHR::Parser::Scanner::DADLScanner.new(@adl_type, @filename, @lineno)
              data = dadl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            when :cadl
              cadl_scanner = OpenEHR::Parser::Scanner::CADLScanner.new(@adl_type, @filename, @lineno)
              data = cadl_scanner.scan(data) do |sym, val|
                yield sym, val
              end
            else
              raise
            end
          end
        end
      end # of TermConstraintScanner

    end
  end
end
