require File.dirname(__FILE__) + '/../../../spec_helper'

# M1 milestone: the smallest possible end-to-end query, "SELECT c FROM
# COMPOSITION c" - a single bare-variable select column and a single
# unpredicated, unnested FROM class expression. WHERE/ORDER BY/LIMIT and
# CONTAINS nesting are deliberately out of scope until their own
# milestones (M2-M7).
describe 'OpenEHR::AQL.parse (M1: minimal query)' do
  it 'parses a single select column bound to the FROM variable' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c')

    expect(query).to be_a(OpenEHR::AQL::Model::Query)
    expect(query.select_clause.columns.size).to eq(1)

    column = query.select_clause.columns.first
    expect(column).to be_a(OpenEHR::AQL::Model::SelectColumn)
    expect(column.alias_name).to be_nil
    expect(column.expression).to be_a(OpenEHR::AQL::Model::IdentifiedPath)
    expect(column.expression.variable).to eq('c')
    expect(column.expression.path).to be_nil
  end

  it 'parses the FROM class expression and its bound variable' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c')

    from = query.from_clause.containment
    expect(from).to be_a(OpenEHR::AQL::Model::ClassExpression)
    expect(from.class_name).to eq('COMPOSITION')
    expect(from.variable).to eq('c')
  end

  it 'allows a FROM class expression with no bound variable' do
    query = OpenEHR::AQL.parse('SELECT 1 FROM COMPOSITION')
    expect(query.from_clause.containment.variable).to be_nil
  end

  it 'is case-insensitive on keywords' do
    query = OpenEHR::AQL.parse('select c from composition c')
    expect(query.from_clause.containment.class_name).to eq('composition')
  end

  it 'defaults select_clause.distinct to false' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c')
    expect(query.select_clause.distinct).to be false
  end

  it 'raises a ParseError with line/column when SELECT has no columns' do
    expect { OpenEHR::AQL.parse('SELECT FROM COMPOSITION c') }
      .to raise_error(OpenEHR::AQL::ParseError) { |e| expect(e.line).to eq(1) }
  end

  it 'raises a ParseError when FROM is missing' do
    expect { OpenEHR::AQL.parse('SELECT c') }.to raise_error(OpenEHR::AQL::ParseError, /FROM/)
  end

  it 'raises a ParseError on trailing input after the FROM clause (e.g. an unsupported WHERE, pre-M5)' do
    expect { OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c WHERE c/name/value = 1') }
      .to raise_error(OpenEHR::AQL::ParseError)
  end
end

# M2 milestone: a SELECT path rooted at a FROM variable (objectPath),
# a standard predicate ("[ehr_id/value=$ehr_id]") bound to that root, and
# a CONTAINS chain nesting further class expressions. Archetype/node
# predicates (M3), WHERE (M5) and AND/OR/NOT CONTAINS (M7) stay out of
# scope until their own milestones.
describe 'OpenEHR::AQL.parse (M2: EHR root, parameters, CONTAINS)' do
  it 'parses a SELECT path rooted at a FROM variable' do
    query = OpenEHR::AQL.parse('SELECT e/ehr_id/value FROM EHR e')
    path = query.select_clause.columns.first.expression

    expect(path.variable).to eq('e')
    expect(path.path).to be_a(OpenEHR::AQL::Model::ObjectPath)
    expect(path.path.segments.map(&:attribute)).to eq(%w[ehr_id value])
  end

  it 'parses a standard predicate with a $parameter operand' do
    query = OpenEHR::AQL.parse('SELECT c FROM EHR e[ehr_id/value=$ehr_id] CONTAINS COMPOSITION c')
    predicate = query.from_clause.containment.parent.predicate

    expect(predicate).to be_a(OpenEHR::AQL::Model::StandardPredicate)
    expect(predicate.path.segments.map(&:attribute)).to eq(%w[ehr_id value])
    expect(predicate.operator).to eq('=')
    expect(predicate.operand).to be_a(OpenEHR::AQL::Model::Parameter)
    expect(predicate.operand.name).to eq('ehr_id')
  end

  it 'parses a standard predicate with a literal string operand' do
    query = OpenEHR::AQL.parse("SELECT c FROM EHR[ehr_id/value='1234'] CONTAINS COMPOSITION c")
    predicate = query.from_clause.containment.parent.predicate

    expect(predicate.operand).to be_a(OpenEHR::AQL::Model::Literal)
    expect(predicate.operand.value).to eq('1234')
  end

  it 'parses a single-level CONTAINS chain' do
    query = OpenEHR::AQL.parse('SELECT c FROM EHR e CONTAINS COMPOSITION c')
    containment = query.from_clause.containment

    expect(containment).to be_a(OpenEHR::AQL::Model::Containment)
    expect(containment.parent.class_name).to eq('EHR')
    expect(containment.child).to be_a(OpenEHR::AQL::Model::ClassExpression)
    expect(containment.child.class_name).to eq('COMPOSITION')
    expect(containment.child.variable).to eq('c')
  end

  it 'parses a multi-level CONTAINS chain (right-recursive)' do
    query = OpenEHR::AQL.parse('SELECT o FROM EHR CONTAINS COMPOSITION CONTAINS OBSERVATION o')
    outer = query.from_clause.containment
    inner = outer.child

    expect(outer.parent.class_name).to eq('EHR')
    expect(inner).to be_a(OpenEHR::AQL::Model::Containment)
    expect(inner.parent.class_name).to eq('COMPOSITION')
    expect(inner.child.class_name).to eq('OBSERVATION')
    expect(inner.child.variable).to eq('o')
  end

  it 'parses EHR root + predicate + CONTAINS + multi-column path SELECT end to end' do
    query = OpenEHR::AQL.parse('SELECT e/ehr_id/value, c FROM EHR e [ehr_id/value=$ehr_id] CONTAINS COMPOSITION c')

    expect(query.select_clause.columns.size).to eq(2)
    expect(query.select_clause.columns[1].expression.variable).to eq('c')
  end
end
