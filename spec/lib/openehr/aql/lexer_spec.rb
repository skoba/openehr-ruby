require File.dirname(__FILE__) + '/../../../spec_helper'

# M0 milestone: keywords (case-insensitive), identifiers, archetype-id
# tokens, at/id-codes, strings, numbers, $parameters, operators/symbols,
# and '--' comments. DATE/TIME/DATETIME literals, TERM_CODE, URI and
# CONTAINED_REGEX are deferred to the milestone that first needs them
# (none of them appear in this corpus).
describe OpenEHR::AQL::Lexer do
  def tokenize(source)
    OpenEHR::AQL::Lexer.new(source).tokenize
  end

  def types(source)
    tokenize(source).map(&:type)
  end

  describe 'whitespace and EOF' do
    it 'tokenizes an empty string as just EOF' do
      expect(types('')).to eq([:eof])
    end

    it 'skips spaces, tabs and newlines between tokens' do
      expect(types(" \t SELECT \n FROM\r\n")).to eq(%i[select from eof])
    end
  end

  describe 'keywords' do
    it 'recognises every clause keyword' do
      source = 'SELECT AS FROM WHERE ORDER BY DESC DESCENDING ASC ASCENDING LIMIT OFFSET'
      expect(types(source)).to eq(%i[select as from where order by desc descending asc ascending limit offset eof])
    end

    it 'recognises operator and predicate keywords' do
      source = 'DISTINCT CONTAINS AND OR NOT EXISTS LIKE MATCHES VERSION LATEST_VERSION ALL_VERSIONS NULL'
      expect(types(source)).to eq(%i[distinct contains and or not exists like matches version latest_version
                                      all_versions null eof])
    end

    it 'recognises function-name keywords' do
      source = 'COUNT MIN MAX SUM AVG TERMINOLOGY LENGTH POSITION SUBSTRING CONCAT CONCAT_WS ABS MOD CEIL FLOOR ' \
               'ROUND NOW CURRENT_DATE CURRENT_TIME CURRENT_DATE_TIME CURRENT_TIMEZONE'
      expect(types(source)).to eq(%i[count min max sum avg terminology length position substring concat concat_ws
                                      abs mod ceil floor round now current_date current_time current_date_time
                                      current_timezone eof])
    end

    it 'recognises the deprecated TOP/FORWARD/BACKWARD keywords' do
      expect(types('TOP FORWARD BACKWARD')).to eq(%i[top forward backward eof])
    end

    it 'is case-insensitive' do
      expect(types('select From WHERE Contains')).to eq(%i[select from where contains eof])
    end

    it 'keeps the original-case lexeme as the token value' do
      token = tokenize('Select').first
      expect(token.value).to eq('Select')
    end
  end

  describe 'boolean literals' do
    it 'tokenizes true/false (any case) as :boolean' do
      tokens = tokenize('true FALSE True')
      expect(tokens.map(&:type)).to eq(%i[boolean boolean boolean eof])
      expect(tokens[0...-1].map(&:value)).to eq([true, false, true])
    end
  end

  describe 'identifiers' do
    it 'tokenizes a plain lower-case identifier' do
      token = tokenize('systolic').first
      expect(token.type).to eq(:identifier)
      expect(token.value).to eq('systolic')
    end

    it 'allows digits and underscores after the first letter' do
      expect(tokenize('ehr_id_2').first.value).to eq('ehr_id_2')
    end

    it 'does not treat a keyword-prefixed identifier as a keyword' do
      expect(tokenize('selection').first.type).to eq(:identifier)
    end
  end

  describe 'at-codes and id-codes' do
    it 'tokenizes a plain at-code' do
      token = tokenize('at0004').first
      expect(token.type).to eq(:at_code)
      expect(token.value).to eq('at0004')
    end

    it 'tokenizes a specialised at-code with dotted suffix' do
      expect(tokenize('at0002.1').first.value).to eq('at0002.1')
    end

    it 'tokenizes an id-code' do
      token = tokenize('id5').first
      expect(token.type).to eq(:id_code)
      expect(token.value).to eq('id5')
    end
  end

  describe 'URI tokens' do
    it 'tokenizes a scheme://authority/path?query URI' do
      token = tokenize('terminology://snomed-ct/hierarchy?rootConceptId=50043002').first
      expect(token.type).to eq(:uri)
      expect(token.value).to eq('terminology://snomed-ct/hierarchy?rootConceptId=50043002')
    end

    it 'does not misparse an archetype id (no colon) as a URI' do
      expect(tokenize('openEHR-EHR-OBSERVATION.blood_pressure.v1').first.type).to eq(:archetype_hrid)
    end
  end

  describe 'archetype-id tokens' do
    it 'tokenizes a full archetype HRID' do
      token = tokenize('openEHR-EHR-OBSERVATION.blood_pressure.v1').first
      expect(token.type).to eq(:archetype_hrid)
      expect(token.value).to eq('openEHR-EHR-OBSERVATION.blood_pressure.v1')
    end

    it 'tokenizes an archetype HRID with a hyphenated concept id' do
      token = tokenize('openEHR-EHR-EVALUATION.problem-diagnosis.v1').first
      expect(token.value).to eq('openEHR-EHR-EVALUATION.problem-diagnosis.v1')
    end
  end

  describe 'numeric literals' do
    it 'tokenizes an integer' do
      token = tokenize('140').first
      expect(token.type).to eq(:integer)
      expect(token.value).to eq(140)
    end

    it 'tokenizes a real number' do
      token = tokenize('12.5').first
      expect(token.type).to eq(:real)
      expect(token.value).to eq(12.5)
    end

    it 'tokenizes scientific-notation integers and reals' do
      tokens = tokenize('1e10 2.5e-3')
      expect(tokens.map(&:type)).to eq(%i[sci_integer sci_real eof])
      expect(tokens[0...-1].map(&:value)).to eq([1e10, 2.5e-3])
    end

    it 'tokenizes a leading unary minus as its own symbol token' do
      expect(types('-90')).to eq(%i[minus integer eof])
    end
  end

  describe 'string literals' do
    it 'tokenizes a single-quoted string' do
      token = tokenize("'CEC'").first
      expect(token.type).to eq(:string)
      expect(token.value).to eq('CEC')
    end

    it 'tokenizes a double-quoted string' do
      expect(tokenize('"alert"').first.value).to eq('alert')
    end

    it 'supports common backslash escapes' do
      expect(tokenize("'it\\'s'").first.value).to eq("it's")
      expect(tokenize('"line1\\nline2"').first.value).to eq("line1\nline2")
    end

    it 'raises a ParseError on an unterminated string' do
      expect { tokenize("'unterminated") }.to raise_error(OpenEHR::AQL::ParseError, /unterminated string/i)
    end
  end

  describe 'parameters' do
    it 'tokenizes a $parameter' do
      token = tokenize('$ehrUid').first
      expect(token.type).to eq(:parameter)
      expect(token.value).to eq('ehrUid')
    end
  end

  describe 'operators and symbols' do
    it 'tokenizes comparison operators' do
      tokens = tokenize('= != < <= > >=')
      expect(tokens.map(&:type)).to eq(Array.new(6, :comparison_operator) + [:eof])
      expect(tokens[0...-1].map(&:value)).to eq(%w[= != < <= > >=])
    end

    it 'tokenizes structural symbols' do
      source = ', / * + ( ) [ ] { }'
      expect(types(source)).to eq(%i[comma slash asterisk plus left_paren right_paren left_bracket right_bracket
                                      left_curly right_curly eof])
    end
  end

  describe 'comments' do
    it 'skips a "-- text" line comment up to the newline' do
      expect(types("SELECT -- this is ignored\nFROM")).to eq(%i[select from eof])
    end

    it 'skips a "-- text" line comment that runs to EOF' do
      expect(types('SELECT -- trailing comment')).to eq(%i[select eof])
    end

    it 'skips an empty "--" comment at end of line' do
      expect(types("SELECT --\nFROM")).to eq(%i[select from eof])
    end

    it 'tokenizes a bare "--" not followed by a space as its own symbol' do
      expect(types('SELECT --c FROM')).to eq(%i[select double_dash identifier from eof])
    end
  end

  describe 'line/column tracking' do
    it 'reports 1-based line and column for each token' do
      tokens = tokenize("SELECT c\nFROM COMPOSITION c")
      select_tok, c_tok, from_tok = tokens
      expect([select_tok.line, select_tok.column]).to eq([1, 1])
      expect([c_tok.line, c_tok.column]).to eq([1, 8])
      expect([from_tok.line, from_tok.column]).to eq([2, 1])
    end
  end

  describe 'tokenizing a full official example query' do
    it 'tokenizes "SELECT c FROM EHR e[...] CONTAINS COMPOSITION c" end to end' do
      source = <<~AQL
        SELECT c
        FROM EHR e[ehr_id/value=$ehrUid]
            CONTAINS COMPOSITION c
      AQL
      expect(types(source)).to eq(%i[
        select identifier
        from identifier identifier left_bracket identifier slash identifier comparison_operator parameter right_bracket
        contains identifier identifier
        eof
      ])
    end
  end
end
