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

  it 'raises a ParseError on trailing input after the FROM clause' do
    expect { OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c GARBAGE') }
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

# M3 milestone: archetype containment, i.e. an ARCHETYPE_HRID predicate on
# a class expression: "OBSERVATION o [openEHR-EHR-OBSERVATION.blood_pressure.v1]".
# nodePredicate (bare at-codes for SELECT path segments) is M4's job.
describe 'OpenEHR::AQL.parse (M3: archetype containment)' do
  it 'parses an archetype predicate on the FROM class expression' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c [openEHR-EHR-COMPOSITION.encounter.v1]')
    predicate = query.from_clause.containment.predicate

    expect(predicate).to be_a(OpenEHR::AQL::Model::ArchetypePredicate)
    expect(predicate.archetype_id).to eq('openEHR-EHR-COMPOSITION.encounter.v1')
  end

  it 'parses archetype predicates through a two-level CONTAINS chain' do
    query = OpenEHR::AQL.parse(<<~AQL)
      SELECT o
      FROM EHR
         CONTAINS COMPOSITION [openEHR-EHR-COMPOSITION.encounter.v1]
            CONTAINS OBSERVATION o [openEHR-EHR-OBSERVATION.blood_pressure.v1]
    AQL

    inner = query.from_clause.containment.child
    composition = inner.parent
    observation = inner.child

    expect(composition.predicate.archetype_id).to eq('openEHR-EHR-COMPOSITION.encounter.v1')
    expect(observation.predicate.archetype_id).to eq('openEHR-EHR-OBSERVATION.blood_pressure.v1')
    expect(observation.variable).to eq('o')
  end

  it 'allows a class expression with neither a variable nor a predicate' do
    query = OpenEHR::AQL.parse('SELECT c FROM EHR CONTAINS COMPOSITION c')
    expect(query.from_clause.containment.parent.predicate).to be_nil
  end
end

# M4 milestone: SELECT paths whose segments carry a bare at-code node
# predicate ("data[at0001]/events[at0006]/.../value/magnitude"), plus an
# AS alias. The SYM_COMMA name/param suffix and AND/OR forms of
# nodePredicate, and node predicates that hold an ARCHETYPE_HRID (used by
# WHERE's EXISTS c/content[archetype-id], M5), are deferred until an
# example needs them.
describe 'OpenEHR::AQL.parse (M4: SELECT paths with node predicates + alias)' do
  it 'parses a deep path with bare at-code predicates on several segments' do
    query = OpenEHR::AQL.parse(
      'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude FROM OBSERVATION o'
    )
    path = query.select_clause.columns.first.expression
    segments = path.path.segments

    expect(segments.map(&:attribute)).to eq(%w[data events data items value magnitude])
    expect(segments[0].predicate).to be_a(OpenEHR::AQL::Model::NodePredicate)
    expect(segments[0].predicate.code).to eq('at0001')
    expect(segments[1].predicate.code).to eq('at0006')
    expect(segments[2].predicate.code).to eq('at0003')
    expect(segments[3].predicate.code).to eq('at0004')
    expect(segments[4].predicate).to be_nil
    expect(segments[5].predicate).to be_nil
  end

  it 'parses an AS alias on a deep path' do
    query = OpenEHR::AQL.parse(
      'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic FROM OBSERVATION o'
    )
    expect(query.select_clause.columns.first.alias_name).to eq('systolic')
  end

  it 'parses an id-code node predicate' do
    query = OpenEHR::AQL.parse('SELECT o/items[id5]/value FROM OBSERVATION o')
    predicate = query.select_clause.columns.first.expression.path.segments.first.predicate
    expect(predicate.code).to eq('id5')
  end

  it 'parses the official blood-pressure-values example end to end' do
    query = OpenEHR::AQL.parse(<<~AQL)
      SELECT
         o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude
      FROM
         EHR [ehr_id/value='1234']
            CONTAINS COMPOSITION [openEHR-EHR-COMPOSITION.encounter.v1]
               CONTAINS OBSERVATION o [openEHR-EHR-OBSERVATION.blood_pressure.v1]
    AQL

    expect(query.select_clause.columns.first.expression.path.segments.map(&:attribute))
      .to eq(%w[data events data items value magnitude])
  end
end

# M5 milestone: WHERE - comparisons, AND/OR/NOT with standard precedence
# (NOT tightest, then AND, then OR) and explicit parens, EXISTS, LIKE, and
# MATCHES against a literal value list. MATCHES against a URI or a
# TERMINOLOGY(...) function call needs lexer support (URI tokens) not yet
# added, and is deferred to a follow-up increment.
describe 'OpenEHR::AQL.parse (M5: WHERE clause)' do
  it 'parses a simple comparison' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c WHERE c/name/value = 1')
    expr = query.where_clause.expression

    expect(expr).to be_a(OpenEHR::AQL::Model::Comparison)
    expect(expr.left.variable).to eq('c')
    expect(expr.operator).to eq('=')
    expect(expr.right).to be_a(OpenEHR::AQL::Model::Literal)
    expect(expr.right.value).to eq(1)
  end

  it 'parses OR of two comparisons (the blood-pressure-threshold shape)' do
    query = OpenEHR::AQL.parse(
      'SELECT c FROM COMPOSITION c WHERE o/data[at0004]/value/magnitude >= 140 OR o/data[at0005]/value/magnitude >= 90'
    )
    expr = query.where_clause.expression
    expect(expr).to be_a(OpenEHR::AQL::Model::OrExpr)
    expect(expr.left).to be_a(OpenEHR::AQL::Model::Comparison)
    expect(expr.right).to be_a(OpenEHR::AQL::Model::Comparison)
  end

  it 'binds AND tighter than OR (no parens needed)' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c WHERE a/x = 1 OR b/y = 2 AND c/z = 3')
    expr = query.where_clause.expression

    expect(expr).to be_a(OpenEHR::AQL::Model::OrExpr)
    expect(expr.left).to be_a(OpenEHR::AQL::Model::Comparison)
    expect(expr.right).to be_a(OpenEHR::AQL::Model::AndExpr)
  end

  it 'parses NOT (EXISTS ... AND ...) with explicit parens' do
    query = OpenEHR::AQL.parse(
      "SELECT e/ehr_id/value FROM EHR e CONTAINS COMPOSITION c " \
      "WHERE NOT (EXISTS c/content[openEHR-EHR-ADMIN_ENTRY.discharge.v1] AND " \
      "e/ehr_status/subject/external_ref/namespace = 'CEC')"
    )
    expr = query.where_clause.expression

    expect(expr).to be_a(OpenEHR::AQL::Model::NotExpr)
    expect(expr.operand).to be_a(OpenEHR::AQL::Model::AndExpr)
    expect(expr.operand.left).to be_a(OpenEHR::AQL::Model::ExistsExpr)
  end

  it 'parses "NOT EXISTS ... OR ..." with NOT binding only to EXISTS' do
    query = OpenEHR::AQL.parse(
      "SELECT e/ehr_id/value FROM EHR e CONTAINS COMPOSITION c " \
      "WHERE NOT EXISTS c/content[openEHR-EHR-ADMIN_ENTRY.discharge.v1] OR " \
      "e/ehr_status/subject/external_ref/namespace != 'CEC'"
    )
    expr = query.where_clause.expression

    expect(expr).to be_a(OpenEHR::AQL::Model::OrExpr)
    expect(expr.left).to be_a(OpenEHR::AQL::Model::NotExpr)
    expect(expr.left.operand).to be_a(OpenEHR::AQL::Model::ExistsExpr)
    expect(expr.right).to be_a(OpenEHR::AQL::Model::Comparison)
  end

  it 'parses a plain EXISTS' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c WHERE EXISTS c/name/value')
    expect(query.where_clause.expression).to be_a(OpenEHR::AQL::Model::ExistsExpr)
  end

  it 'parses LIKE with a string operand' do
    query = OpenEHR::AQL.parse("SELECT c FROM COMPOSITION c WHERE c/context/start_time LIKE '2019-0?-*'")
    expr = query.where_clause.expression

    expect(expr).to be_a(OpenEHR::AQL::Model::LikeExpr)
    expect(expr.operand.value).to eq('2019-0?-*')
  end

  it 'parses MATCHES against a literal value list' do
    query = OpenEHR::AQL.parse(
      "SELECT c FROM COMPOSITION c WHERE c/name/value matches {'18919-1', '18961-3', '19000-9'}"
    )
    expr = query.where_clause.expression

    expect(expr).to be_a(OpenEHR::AQL::Model::MatchesExpr)
    expect(expr.operand).to be_a(OpenEHR::AQL::Model::MatchesValueList)
    expect(expr.operand.items.map(&:value)).to eq(%w[18919-1 18961-3 19000-9])
  end

  it 'parses the official LIKE example end to end' do
    query = OpenEHR::AQL.parse(<<~AQL)
      SELECT
         e/ehr_id/value, c/context/start_time
      FROM
         EHR e
            CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.administrative_encounter.v1]
               CONTAINS ADMIN_ENTRY admission[openEHR-EHR-ADMIN_ENTRY.admission.v1]
      WHERE
         c/context/start_time LIKE '2019-0?-*'
    AQL

    expect(query.where_clause.expression).to be_a(OpenEHR::AQL::Model::LikeExpr)
  end
end

# M6 milestone: DISTINCT, the deprecated TOP N form, ORDER BY (single and
# multiple, ASC default / DESC), and LIMIT/OFFSET.
describe 'OpenEHR::AQL.parse (M6: DISTINCT/TOP/ORDER BY/LIMIT/OFFSET)' do
  it 'parses SELECT DISTINCT' do
    query = OpenEHR::AQL.parse('SELECT DISTINCT c/name/value FROM COMPOSITION c')
    expect(query.select_clause.distinct).to be true
  end

  it 'parses the deprecated SELECT TOP N form' do
    query = OpenEHR::AQL.parse('SELECT TOP 10 c/name/value FROM COMPOSITION c')
    expect(query.select_clause.top).to be_a(OpenEHR::AQL::Model::Top)
    expect(query.select_clause.top.count).to eq(10)
    expect(query.select_clause.top.direction).to be_nil
  end

  it 'parses ORDER BY with a default (ascending) direction' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c ORDER BY c/context/start_time')
    item = query.order_by_clause.items.first

    expect(item.path.variable).to eq('c')
    expect(item.direction).to eq(:asc)
  end

  it 'parses ORDER BY DESC and multiple comma-separated paths' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c ORDER BY c/context/start_time DESC, c/name/value')
    items = query.order_by_clause.items

    expect(items.size).to eq(2)
    expect(items[0].direction).to eq(:desc)
    expect(items[1].direction).to eq(:asc)
  end

  it 'parses LIMIT alone (offset defaults to 0)' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c LIMIT 10')
    expect(query.limit_clause.limit).to eq(10)
    expect(query.limit_clause.offset).to eq(0)
  end

  it 'parses LIMIT with OFFSET' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c LIMIT 10 OFFSET 20')
    expect(query.limit_clause.limit).to eq(10)
    expect(query.limit_clause.offset).to eq(20)
  end

  it 'parses the official SELECT DISTINCT example end to end' do
    query = OpenEHR::AQL.parse(<<~AQL)
      SELECT DISTINCT
         c/name/value AS Name, c/composer/name AS Composer
      FROM
         EHR e[ehr_id/value=$ehrUid]
            CONTAINS COMPOSITION c
    AQL
    expect(query.select_clause.distinct).to be true
  end

  it 'parses the official ORDER BY + LIMIT/OFFSET example end to end' do
    query = OpenEHR::AQL.parse(<<~AQL)
      SELECT
         c/name/value AS Name, c/context/start_time AS date_time, c/composer/name AS Composer
      FROM
         EHR e[ehr_id/value=$ehrUid]
            CONTAINS COMPOSITION c
      ORDER BY c/context/start_time
      LIMIT 10 OFFSET 10
    AQL
    expect(query.order_by_clause.items.first.direction).to eq(:asc)
    expect(query.limit_clause.limit).to eq(10)
    expect(query.limit_clause.offset).to eq(10)
  end
end

# M7 milestone: boolean containment - NOT CONTAINS (a negated
# parent/child containment edge) and AND/OR grouping of sibling
# containment branches, with the same "AND binds tighter than OR"
# precedence as WHERE (M5).
describe 'OpenEHR::AQL.parse (M7: boolean containment)' do
  it 'parses a plain CONTAINS as not negated' do
    query = OpenEHR::AQL.parse('SELECT c FROM EHR e CONTAINS COMPOSITION c')
    expect(query.from_clause.containment.negated).to be false
  end

  it 'parses NOT CONTAINS' do
    query = OpenEHR::AQL.parse('SELECT e/ehr_id/value FROM EHR e CONTAINS COMPOSITION c NOT CONTAINS ADMIN_ENTRY admission')
    inner = query.from_clause.containment.child
    expect(inner).to be_a(OpenEHR::AQL::Model::Containment)
    expect(inner.negated).to be true
    expect(inner.child.class_name).to eq('ADMIN_ENTRY')
  end

  it 'parses AND-grouped sibling containment branches' do
    query = OpenEHR::AQL.parse(
      'SELECT c FROM EHR CONTAINS COMPOSITION c CONTAINS (OBSERVATION o1 AND OBSERVATION o2)'
    )
    branches = query.from_clause.containment.child.child

    expect(branches).to be_a(OpenEHR::AQL::Model::ContainmentAnd)
    expect(branches.left).to be_a(OpenEHR::AQL::Model::ClassExpression)
    expect(branches.left.variable).to eq('o1')
    expect(branches.right.variable).to eq('o2')
  end

  it 'parses OR-grouped sibling containment branches' do
    query = OpenEHR::AQL.parse('SELECT c FROM EHR CONTAINS (COMPOSITION c1 OR COMPOSITION c2)')
    branches = query.from_clause.containment.child

    expect(branches).to be_a(OpenEHR::AQL::Model::ContainmentOr)
    expect(branches.left.variable).to eq('c1')
    expect(branches.right.variable).to eq('c2')
  end

  it 'binds AND tighter than OR inside a containment group' do
    query = OpenEHR::AQL.parse('SELECT c FROM EHR CONTAINS (COMPOSITION c1 OR COMPOSITION c2 AND COMPOSITION c3)')
    top = query.from_clause.containment.child

    expect(top).to be_a(OpenEHR::AQL::Model::ContainmentOr)
    expect(top.left.variable).to eq('c1')
    expect(top.right).to be_a(OpenEHR::AQL::Model::ContainmentAnd)
  end

  it 'parses the official NOT CONTAINS example end to end' do
    query = OpenEHR::AQL.parse(<<~AQL)
      SELECT
         e/ehr_id/value
      FROM
         EHR e
            CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.administrative_encounter.v1]
               NOT CONTAINS ADMIN_ENTRY admission[openEHR-EHR-ADMIN_ENTRY.admission.v1]
      WHERE
         e/ehr_status/subject/external_ref/namespace != 'CEC'
    AQL

    expect(query.from_clause.containment.child.negated).to be true
  end
end
