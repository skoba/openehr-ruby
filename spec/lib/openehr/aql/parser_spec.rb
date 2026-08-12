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
