require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/fixtures/blood_pressure_builder'

# E2 milestone: the minimal end-to-end execution vertical slice,
# "SELECT c FROM COMPOSITION c" - contains_resolver binding a bare class
# expression against a Dataset's compositions, path_evaluator resolving a
# bare identifiedPath to the bound object, and ResultSet assembling the
# rows. EHR roots, CONTAINS nesting, predicates, WHERE, ORDER BY/LIMIT and
# functions are added by later engine milestones.
describe 'OpenEHR::AQL.execute (E2: minimal query)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:bp_composition) { builder.blood_pressure_composition(systolic: 150, diastolic: 95) }
  let(:temp_composition) { builder.body_temperature_composition }

  it 'returns one row per matching composition, binding the FROM variable' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([bp_composition, temp_composition])
    result = OpenEHR::AQL.execute('SELECT c FROM COMPOSITION c', dataset)

    expect(result).to be_a(OpenEHR::AQL::ResultSet)
    expect(result.columns).to eq(['c'])
    expect(result.rows).to eq([[bp_composition], [temp_composition]])
  end

  it 'is Enumerable over its rows' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([bp_composition])
    result = OpenEHR::AQL.execute('SELECT c FROM COMPOSITION c', dataset)

    expect(result.to_a).to eq([[bp_composition]])
    expect(result.size).to eq(1)
  end

  it 'accepts a bare Array of compositions via Dataset.wrap (OpenEHR::AQL.execute(aql, [comp1, comp2]))' do
    result = OpenEHR::AQL.execute('SELECT c FROM COMPOSITION c', [bp_composition, temp_composition])
    expect(result.rows.size).to eq(2)
  end

  it 'returns no rows when the dataset has no matching compositions' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([])
    result = OpenEHR::AQL.execute('SELECT c FROM COMPOSITION c', dataset)
    expect(result.rows).to eq([])
  end

  it 'runs from an already-parsed Query via Query#execute' do
    query = OpenEHR::AQL.parse('SELECT c FROM COMPOSITION c')
    dataset = OpenEHR::AQL::Dataset.of_compositions([bp_composition])
    expect(query.execute(dataset).rows).to eq([[bp_composition]])
  end

  it 'spans multiple EHR records in the dataset' do
    dataset = OpenEHR::AQL::Dataset.new(ehrs: [
      { ehr_id: 'e1', compositions: [bp_composition] },
      { ehr_id: 'e2', compositions: [temp_composition] }
    ])
    result = OpenEHR::AQL.execute('SELECT c FROM COMPOSITION c', dataset)
    expect(result.rows).to eq([[bp_composition], [temp_composition]])
  end
end

# E3 milestone: an EHR root variable, a CONTAINS chain reaching several
# levels deep into a composition's subtree, and archetype-predicate
# filtering ("CONTAINS OBSERVATION o [openEHR-EHR-OBSERVATION.blood_pressure.v1]"
# matches the BP observation, not the body-temperature one). WHERE,
# ORDER BY/LIMIT, boolean containment and SELECT paths beyond a bare
# variable are added by later engine milestones.
describe 'OpenEHR::AQL.execute (E3: EHR root, CONTAINS chain, archetype predicate)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:bp_composition) { builder.blood_pressure_composition(systolic: 150, diastolic: 95) }
  let(:temp_composition) { builder.body_temperature_composition }

  it 'binds both the EHR root variable and a CONTAINS-matched composition' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([bp_composition], ehr_id: 'ehr-1')
    result = OpenEHR::AQL.execute('SELECT c FROM EHR e CONTAINS COMPOSITION c', dataset)
    expect(result.rows).to eq([[bp_composition]])
  end

  it 'reaches an OBSERVATION nested two CONTAINS levels below EHR' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([bp_composition])
    result = OpenEHR::AQL.execute('SELECT o FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o', dataset)
    observation = bp_composition.item_at_path('/content[openEHR-EHR-OBSERVATION.blood_pressure.v1]')
    expect(result.rows).to eq([[observation]])
  end

  it 'filters by archetype predicate, matching only the blood_pressure observation' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([bp_composition, temp_composition])
    result = OpenEHR::AQL.execute(
      'SELECT o FROM EHR e CONTAINS COMPOSITION c ' \
      'CONTAINS OBSERVATION o [openEHR-EHR-OBSERVATION.blood_pressure.v1]', dataset
    )
    expect(result.rows.size).to eq(1)
    expect(result.rows.first.first.archetype_node_id).to eq('openEHR-EHR-OBSERVATION.blood_pressure.v1')
  end

  it 'returns no rows when the archetype predicate matches nothing' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([temp_composition])
    result = OpenEHR::AQL.execute(
      'SELECT o FROM EHR e CONTAINS COMPOSITION c ' \
      'CONTAINS OBSERVATION o [openEHR-EHR-OBSERVATION.blood_pressure.v1]', dataset
    )
    expect(result.rows).to eq([])
  end

  it 'filters the intermediate COMPOSITION by its own archetype predicate too' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([bp_composition])
    result = OpenEHR::AQL.execute(
      'SELECT c FROM EHR e CONTAINS COMPOSITION c [openEHR-EHR-COMPOSITION.encounter.v1]', dataset
    )
    expect(result.rows).to eq([[bp_composition]])
  end
end

# E4 milestone: SELECT paths beyond a bare variable - walking Pathable's
# declared path_attribute chain via items_at_path (with node/archetype
# predicates), then falling through to a whitelisted public_send for the
# trailing non-Pathable hop (a DV_QUANTITY's "magnitude", reached only
# after "value" already navigated onto it). WHERE, ORDER BY/LIMIT and
# functions are added by later engine milestones.
describe 'OpenEHR::AQL.execute (E4: SELECT paths)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:bp_composition) { builder.blood_pressure_composition(systolic: 150, diastolic: 95) }

  def bp_dataset
    OpenEHR::AQL::Dataset.of_compositions([bp_composition])
  end

  it 'walks a deep path down to a DV_QUANTITY magnitude' do
    result = OpenEHR::AQL.execute(
      'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude ' \
      'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o', bp_dataset
    )
    expect(result.rows).to eq([[150]])
  end

  it 'walks a deep path down to the diastolic magnitude, aliased' do
    result = OpenEHR::AQL.execute(
      'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude AS diastolic ' \
      'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o', bp_dataset
    )
    expect(result.columns).to eq(['diastolic'])
    expect(result.rows).to eq([[95]])
  end

  it 'evaluates two path columns in the same row' do
    result = OpenEHR::AQL.execute(
      'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic, ' \
      'o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude AS diastolic ' \
      'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o', bp_dataset
    )
    expect(result.rows).to eq([[150, 95]])
  end

  it 'reaches a DV_TEXT value without a trailing non-Pathable hop' do
    result = OpenEHR::AQL.execute('SELECT c/name FROM EHR e CONTAINS COMPOSITION c', bp_dataset)
    expect(result.rows.first.first.value).to eq('Encounter')
  end

  it 'resolves a path with no matching node (e.g. a wrong at-code) to nil, not an error' do
    result = OpenEHR::AQL.execute(
      'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at9999]/value/magnitude ' \
      'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o', bp_dataset
    )
    expect(result.rows).to eq([[nil]])
  end

  it 'raises ExecutionError for an unsupported trailing attribute hop' do
    expect {
      OpenEHR::AQL.execute(
        'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/not_a_real_attribute ' \
        'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o', bp_dataset
      ).rows
    }.to raise_error(OpenEHR::AQL::ExecutionError, /not_a_real_attribute/)
  end
end

# E5 milestone: WHERE clause execution - the official AQL example's own
# stated acceptance criterion, "returns only the hypertensive rows"
# (systolic >= 140 OR diastolic >= 90). ORDER BY/LIMIT, boolean
# containment execution and functions are added by later engine
# milestones.
describe 'OpenEHR::AQL.execute (E5: WHERE clause)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:normal) { builder.blood_pressure_composition(systolic: 120, diastolic: 80) }
  let(:high_systolic) { builder.blood_pressure_composition(systolic: 150, diastolic: 85) }
  let(:high_diastolic) { builder.blood_pressure_composition(systolic: 130, diastolic: 95) }

  let(:hypertension_query) do
    'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic, ' \
    'o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude AS diastolic ' \
    'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
    'WHERE o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude >= 140 OR ' \
    'o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude >= 90'
  end

  it 'returns only the hypertensive rows (systolic >= 140 OR diastolic >= 90)' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([normal, high_systolic, high_diastolic])
    result = OpenEHR::AQL.execute(hypertension_query, dataset)

    expect(result.rows).to contain_exactly([150, 85], [130, 95])
  end

  it 'returns no rows when nothing matches' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([normal])
    expect(OpenEHR::AQL.execute(hypertension_query, dataset).rows).to eq([])
  end

  it 'filters with a plain AND' do
    query = 'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic ' \
            'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            'WHERE o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude >= 140 AND ' \
            'o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude < 90'
    dataset = OpenEHR::AQL::Dataset.of_compositions([normal, high_systolic, high_diastolic])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([[150]])
  end

  it 'filters with NOT' do
    query = 'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic ' \
            'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            'WHERE NOT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude >= 140'
    dataset = OpenEHR::AQL::Dataset.of_compositions([normal, high_systolic])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([[120]])
  end

  it 'binds a $parameter in the comparison operand' do
    query = 'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic ' \
            'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            'WHERE o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude >= $threshold'
    dataset = OpenEHR::AQL::Dataset.of_compositions([normal, high_systolic])
    result = OpenEHR::AQL.execute(query, dataset, params: { threshold: 140 })
    expect(result.rows).to eq([[150]])
  end

  it 'raises UnboundParameterError for a $parameter with no binding supplied' do
    query = 'SELECT c FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            'WHERE o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude >= $threshold'
    dataset = OpenEHR::AQL::Dataset.of_compositions([normal])
    expect { OpenEHR::AQL.execute(query, dataset).rows }.to raise_error(OpenEHR::AQL::UnboundParameterError, /threshold/)
  end

  it 'evaluates EXISTS as true for a present path' do
    query = 'SELECT c FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            'WHERE EXISTS o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude'
    dataset = OpenEHR::AQL::Dataset.of_compositions([normal])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([[normal]])
  end

  it 'evaluates EXISTS as false for an absent path' do
    query = 'SELECT c FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            'WHERE EXISTS o/data[at0001]/events[at0006]/data[at0003]/items[at9999]/value/magnitude'
    dataset = OpenEHR::AQL::Dataset.of_compositions([normal])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([])
  end
end

# E6 milestone: ORDER BY (ascending default, DESC, multiple keys),
# DISTINCT and LIMIT/OFFSET, spliced into the pipeline in the project
# plan's own stated order (CONTAINS -> WHERE -> ORDER BY -> SELECT ->
# DISTINCT/LIMIT/OFFSET). Boolean containment execution and functions
# are added by later engine milestones.
describe 'OpenEHR::AQL.execute (E6: ORDER BY / DISTINCT / LIMIT-OFFSET)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:low) { builder.blood_pressure_composition(systolic: 110, diastolic: 70) }
  let(:mid) { builder.blood_pressure_composition(systolic: 130, diastolic: 85) }
  let(:high) { builder.blood_pressure_composition(systolic: 150, diastolic: 95) }

  def systolic_query(extra = '')
    'SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic ' \
    "FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o #{extra}"
  end

  it 'sorts ascending by default' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([high, low, mid])
    result = OpenEHR::AQL.execute(systolic_query('ORDER BY o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude'), dataset)
    expect(result.rows).to eq([[110], [130], [150]])
  end

  it 'sorts DESC' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([high, low, mid])
    result = OpenEHR::AQL.execute(systolic_query('ORDER BY o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude DESC'), dataset)
    expect(result.rows).to eq([[150], [130], [110]])
  end

  it 'applies LIMIT' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([high, low, mid])
    result = OpenEHR::AQL.execute(
      systolic_query('ORDER BY o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude LIMIT 2'), dataset
    )
    expect(result.rows).to eq([[110], [130]])
  end

  it 'applies LIMIT with OFFSET' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([high, low, mid])
    result = OpenEHR::AQL.execute(
      systolic_query('ORDER BY o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude LIMIT 1 OFFSET 1'), dataset
    )
    expect(result.rows).to eq([[130]])
  end

  it 'applies SELECT DISTINCT, collapsing equal-valued rows' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([mid, mid])
    query = 'SELECT DISTINCT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic ' \
            'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o'
    result = OpenEHR::AQL.execute(query, dataset)
    expect(result.rows).to eq([[130]])
  end
end

# E7 milestone: boolean containment execution - AND-grouped CONTAINS
# branches (both must match, cross-product bindings), OR-grouped
# branches (either matches, union of bindings) and NOT CONTAINS
# (parent matches survive only when the negated class is absent from
# its subtree). Functions/aggregates are added by a later milestone.
describe 'OpenEHR::AQL.execute (E7: boolean containment execution)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:bp_only) { builder.blood_pressure_composition(systolic: 150, diastolic: 95) }
  let(:temp_only) { builder.body_temperature_composition }
  let(:both) do
    builder.encounter(
      bp_only.content.first, temp_only.content.first,
      start_time: '2024-01-01T10:00:00+09:00', composer_name: 'Dr. Test'
    )
  end

  it 'requires both branches of an AND-grouped CONTAINS to match, binding both variables' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([both])
    query = 'SELECT o1, o2 FROM EHR e CONTAINS COMPOSITION c ' \
            'CONTAINS (OBSERVATION o1 [openEHR-EHR-OBSERVATION.blood_pressure.v1] ' \
            'AND OBSERVATION o2 [openEHR-EHR-OBSERVATION.body_temperature.v1])'
    result = OpenEHR::AQL.execute(query, dataset)

    expect(result.rows.size).to eq(1)
    expect(result.rows.first[0].archetype_node_id).to eq('openEHR-EHR-OBSERVATION.blood_pressure.v1')
    expect(result.rows.first[1].archetype_node_id).to eq('openEHR-EHR-OBSERVATION.body_temperature.v1')
  end

  it 'returns no rows when only one branch of an AND-grouped CONTAINS matches' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([bp_only])
    query = 'SELECT o1, o2 FROM EHR e CONTAINS COMPOSITION c ' \
            'CONTAINS (OBSERVATION o1 [openEHR-EHR-OBSERVATION.blood_pressure.v1] ' \
            'AND OBSERVATION o2 [openEHR-EHR-OBSERVATION.body_temperature.v1])'
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([])
  end

  it 'matches when either branch of an OR-grouped CONTAINS matches' do
    query = 'SELECT o FROM EHR e CONTAINS COMPOSITION c ' \
            'CONTAINS (OBSERVATION o [openEHR-EHR-OBSERVATION.blood_pressure.v1] ' \
            'OR OBSERVATION o [openEHR-EHR-OBSERVATION.body_temperature.v1])'
    bp_result = OpenEHR::AQL.execute(query, OpenEHR::AQL::Dataset.of_compositions([bp_only]))
    temp_result = OpenEHR::AQL.execute(query, OpenEHR::AQL::Dataset.of_compositions([temp_only]))

    expect(bp_result.rows.first.first.archetype_node_id).to eq('openEHR-EHR-OBSERVATION.blood_pressure.v1')
    expect(temp_result.rows.first.first.archetype_node_id).to eq('openEHR-EHR-OBSERVATION.body_temperature.v1')
  end

  it 'excludes compositions that DO contain the negated class via NOT CONTAINS' do
    query = 'SELECT c FROM EHR e CONTAINS COMPOSITION c ' \
            'NOT CONTAINS OBSERVATION [openEHR-EHR-OBSERVATION.body_temperature.v1]'
    only_bp_result = OpenEHR::AQL.execute(query, OpenEHR::AQL::Dataset.of_compositions([bp_only]))
    has_temp_result = OpenEHR::AQL.execute(query, OpenEHR::AQL::Dataset.of_compositions([both]))

    expect(only_bp_result.rows).to eq([[bp_only]])
    expect(has_temp_result.rows).to eq([])
  end
end

# E8 milestone: aggregate function execution (COUNT/MIN/MAX/AVG/SUM). A
# SELECT clause made entirely of aggregate columns collapses the whole
# (post-WHERE) binding set into a single summary row; ORDER BY/DISTINCT/
# LIMIT don't apply to it. Mixing aggregate and plain columns, and
# generic (non-aggregate) function calls, are not yet supported.
describe 'OpenEHR::AQL.execute (E8: aggregate functions)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:low) { builder.blood_pressure_composition(systolic: 110, diastolic: 70) }
  let(:mid) { builder.blood_pressure_composition(systolic: 130, diastolic: 85) }
  let(:high) { builder.blood_pressure_composition(systolic: 150, diastolic: 95) }
  let(:dataset) { OpenEHR::AQL::Dataset.of_compositions([low, mid, high]) }

  it 'computes MAX/MIN/AVG over a path, one summary row' do
    query = 'SELECT ' \
            'MAX(o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude) AS maxValue, ' \
            'MIN(o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude) AS minValue, ' \
            'AVG(o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude) AS meanValue ' \
            'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o'
    result = OpenEHR::AQL.execute(query, dataset)

    expect(result.columns).to eq(%w[maxValue minValue meanValue])
    expect(result.rows).to eq([[150, 110, 130.0]])
  end

  it 'computes SUM' do
    query = 'SELECT SUM(o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude) AS total ' \
            'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o'
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([[390]])
  end

  it 'computes COUNT(*)' do
    query = 'SELECT COUNT(*) AS n FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o'
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([[3]])
  end

  it 'computes COUNT(DISTINCT path)' do
    dataset_with_dup = OpenEHR::AQL::Dataset.of_compositions([low, mid, mid])
    query = 'SELECT COUNT(DISTINCT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude) AS n ' \
            'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o'
    expect(OpenEHR::AQL.execute(query, dataset_with_dup).rows).to eq([[2]])
  end

  it 'respects WHERE before aggregating' do
    query = 'SELECT COUNT(*) AS n FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            'WHERE o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude >= 130'
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([[2]])
  end

  it 'aggregates to 0/nil over an empty match set' do
    empty_dataset = OpenEHR::AQL::Dataset.of_compositions([])
    query = 'SELECT COUNT(*) AS n, MAX(o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude) AS m ' \
            'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o'
    expect(OpenEHR::AQL.execute(query, empty_dataset).rows).to eq([[0, nil]])
  end
end

# E9 milestone (cross-consistency): the same query against the same
# underlying data, supplied via Dataset's three accepted shapes -
# a Hash record, a *lazy* bare Enumerator (proving the "construction
# never iterates" promise holds all the way through a real execute),
# and a full OpenEHR::RM::EHR::EHR - must return identical results.
# See lib/openehr/aql/engine/dataset.rb's header comment for the full
# contract this locks in.
describe 'OpenEHR::AQL.execute (E9: Dataset shape cross-consistency)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:composition) { builder.blood_pressure_composition(systolic: 150, diastolic: 95) }
  let(:query) do
    'SELECT e/ehr_id/value AS ehr_id, ' \
    'o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic ' \
    'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o'
  end

  def real_ehr(ehr_id)
    versioned_status = double('VersionedEHRStatus', type: 'VERSIONED_EHR_STATUS', latest_version: double(data: nil))
    versioned_composition = double('VersionedComposition', type: 'VERSIONED_COMPOSITION',
                                    latest_version: double(data: composition))
    OpenEHR::RM::EHR::EHR.new(
      system_id: OpenEHR::RM::Support::Identification::HierObjectID.new(value: 'system-1'),
      ehr_id: OpenEHR::RM::Support::Identification::HierObjectID.new(value: ehr_id),
      time_created: builder.date_time('2024-01-01T00:00:00+09:00'),
      contributions: [double('ObjectRef', type: 'CONTRIBUTION')],
      ehr_access: double('ObjectRef', type: 'VERSIONED_EHR_ACCESS'),
      ehr_status: versioned_status,
      compositions: [versioned_composition]
    )
  end

  it 'returns the same rows from a Hash record, a lazy Enumerator, and a real EHR::EHR' do
    hash_result = OpenEHR::AQL.execute(query, OpenEHR::AQL::Dataset.new(
      ehrs: [{ ehr_id: 'ehr-1', compositions: [composition] }]
    ))

    lazy_source = Enumerator.new { |y| y << { ehr_id: 'ehr-1', compositions: [composition] } }.lazy
    lazy_result = OpenEHR::AQL.execute(query, OpenEHR::AQL::Dataset.new(ehrs: lazy_source))

    ehr_result = OpenEHR::AQL.execute(query, OpenEHR::AQL::Dataset.new(ehrs: [real_ehr('ehr-1')]))

    expect(hash_result.rows).to eq([['ehr-1', 150]])
    expect(lazy_result.rows).to eq(hash_result.rows)
    expect(ehr_result.rows).to eq(hash_result.rows)
  end
end

# E10 milestone: an EHR-level predicate ("[ehr_id/value=$ehr_id]" - the
# canonical per-patient AQL idiom used throughout the official examples)
# is now evaluated, not silently ignored - a FROM EHR class expression's
# predicate used to be dropped entirely (contains_resolver matched every
# EHR record regardless of it). Reuses PredicateEvaluator/PathEvaluator's
# existing comparison machinery rather than new bespoke logic.
describe 'OpenEHR::AQL.execute (E10: EHR-root predicate)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:bp_composition) { builder.blood_pressure_composition(systolic: 150, diastolic: 95) }
  let(:temp_composition) { builder.body_temperature_composition }
  let(:dataset) do
    OpenEHR::AQL::Dataset.new(ehrs: [
      { ehr_id: 'e1', compositions: [bp_composition] },
      { ehr_id: 'e2', compositions: [temp_composition] }
    ])
  end

  it 'filters to only the EHR matching a literal ehr_id predicate' do
    result = OpenEHR::AQL.execute(
      "SELECT e/ehr_id/value AS id FROM EHR e [ehr_id/value='e1'] CONTAINS COMPOSITION c", dataset
    )
    expect(result.rows).to eq([['e1']])
  end

  it 'filters using a $parameter, the idiom used throughout the official AQL examples' do
    result = OpenEHR::AQL.execute(
      'SELECT e/ehr_id/value AS id FROM EHR e [ehr_id/value=$ehrUid] CONTAINS COMPOSITION c',
      dataset, params: { ehrUid: 'e2' }
    )
    expect(result.rows).to eq([['e2']])
  end

  it 'returns no rows when the predicate matches no EHR' do
    result = OpenEHR::AQL.execute(
      "SELECT e/ehr_id/value AS id FROM EHR e [ehr_id/value='e999'] CONTAINS COMPOSITION c", dataset
    )
    expect(result.rows).to eq([])
  end

  it 'filters even when the EHR root has no variable bound' do
    result = OpenEHR::AQL.execute(
      "SELECT c FROM EHR [ehr_id/value='e1'] CONTAINS COMPOSITION c", dataset
    )
    expect(result.rows).to eq([[bp_composition]])
  end

  it 'treats an unresolvable predicate path as never matching, not an error' do
    result = OpenEHR::AQL.execute(
      "SELECT e/ehr_id/value AS id FROM EHR e [some_unknown_key='v'] CONTAINS COMPOSITION c", dataset
    )
    expect(result.rows).to eq([])
  end

  it 'still returns every EHR when there is no predicate at all (regression pin)' do
    result = OpenEHR::AQL.execute('SELECT e/ehr_id/value AS id FROM EHR e CONTAINS COMPOSITION c', dataset)
    expect(result.rows).to eq([['e1'], ['e2']])
  end

  it 'raises ExecutionError for an EHR-root predicate kind it cannot evaluate yet' do
    expect {
      OpenEHR::AQL.execute(
        'SELECT c FROM EHR e [openEHR-EHR-COMPOSITION.encounter.v1] CONTAINS COMPOSITION c', dataset
      )
    }.to raise_error(OpenEHR::AQL::ExecutionError)
  end
end

# E11 milestone: SELECT TOP n (deprecated by QUERY 1.1.0 in favour of
# LIMIT, but still grammatical) used to be parsed into
# SelectClause#top and then silently never read by Engine - "SELECT
# TOP 1 ..." returned every matching row, not just 1. Implemented by
# reusing the LIMIT code path; TOP and LIMIT together have no defined
# meaning, so combining them raises rather than guessing.
describe 'OpenEHR::AQL.execute (E11: SELECT TOP)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:low) { builder.blood_pressure_composition(systolic: 110, diastolic: 70) }
  let(:mid) { builder.blood_pressure_composition(systolic: 130, diastolic: 85) }
  let(:high) { builder.blood_pressure_composition(systolic: 150, diastolic: 95) }

  def systolic_query(top)
    "SELECT TOP #{top} " \
    'o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic ' \
    'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
    'ORDER BY o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude'
  end

  it 'limits to the first n rows (regression: used to return every row)' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([high, low, mid])
    result = OpenEHR::AQL.execute(systolic_query('1'), dataset)
    expect(result.rows).to eq([[110]])
  end

  it 'TOP n BACKWARD takes the last n rows' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([high, low, mid])
    result = OpenEHR::AQL.execute(systolic_query('2 BACKWARD'), dataset)
    expect(result.rows).to eq([[130], [150]])
  end

  it 'raises ExecutionError when TOP and LIMIT are both present' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([high, low, mid])
    query = "#{systolic_query('1')} LIMIT 2"
    expect { OpenEHR::AQL.execute(query, dataset) }.to raise_error(OpenEHR::AQL::ExecutionError, /TOP.*LIMIT/)
  end
end

# E12 milestone: WHERE ... LIKE was parsed into Model::LikeExpr and then
# silently never handled by PredicateEvaluator ("cannot evaluate a
# Model::LikeExpr WHERE expression yet"). The AQL spec's LIKE is a glob
# match (? = one char, * = zero-or-more, whole-string anchored, no
# wildcard at all behaves like =) - not SQL's %/_ - implemented that way.
describe 'OpenEHR::AQL.execute (E12: WHERE ... LIKE)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:blood_pressure) { builder.blood_pressure_composition(systolic: 150, diastolic: 85) }
  let(:body_temperature) { builder.body_temperature_composition }

  def like_query(pattern)
    "SELECT o/name/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o WHERE o/name/value LIKE '#{pattern}'"
  end

  it 'matches a glob pattern with * (zero-or-more)' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure, body_temperature])
    expect(OpenEHR::AQL.execute(like_query('Blood*'), dataset).rows).to eq([['Blood pressure']])
  end

  it 'matches a glob pattern with ? (exactly one char)' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect(OpenEHR::AQL.execute(like_query('Blood pressur?'), dataset).rows).to eq([['Blood pressure']])
  end

  it 'behaves like = when the pattern has no wildcard' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure, body_temperature])
    expect(OpenEHR::AQL.execute(like_query('Blood pressure'), dataset).rows).to eq([['Blood pressure']])
    expect(OpenEHR::AQL.execute(like_query('Blood'), dataset).rows).to eq([])
  end

  it 'requires the whole string to match, not a substring' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect(OpenEHR::AQL.execute(like_query('pressure'), dataset).rows).to eq([])
  end

  it 'binds a $parameter as the LIKE pattern' do
    query = 'SELECT o/name/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            'WHERE o/name/value LIKE $pattern'
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure, body_temperature])
    result = OpenEHR::AQL.execute(query, dataset, params: { pattern: 'Body*' })
    expect(result.rows).to eq([['Body temperature']])
  end
end

# E13 milestone: WHERE ... MATCHES {...} was parsed into Model::MatchesExpr
# (with a MatchesValueList/UriRef/TerminologyFunctionCall operand) and then
# silently never handled. A value list is a pure in-memory membership
# check, implemented fully; a URI/TERMINOLOGY(...) operand names an
# external value-set/terminology-server lookup this engine has no
# terminology service wired for (OpenEHR::TerminologyService validates a
# single known code, it doesn't expand a value set) - raises a clear,
# explanatory ExecutionError instead of silently guessing or matching
# everything.
describe 'OpenEHR::AQL.execute (E13: WHERE ... MATCHES)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:blood_pressure) { builder.blood_pressure_composition(systolic: 150, diastolic: 85) }
  let(:body_temperature) { builder.body_temperature_composition }

  it 'matches when the value is in the literal value list' do
    query = "SELECT o/name/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o " \
            "WHERE o/name/value MATCHES {'Blood pressure', 'Something else'}"
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure, body_temperature])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([['Blood pressure']])
  end

  it 'does not match when the value is absent from the list' do
    query = "SELECT o/name/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o " \
            "WHERE o/name/value MATCHES {'Something else'}"
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([])
  end

  it 'resolves a $parameter inside the value list' do
    query = 'SELECT o/name/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            "WHERE o/name/value MATCHES {\$name, 'Something else'}"
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    result = OpenEHR::AQL.execute(query, dataset, params: { name: 'Blood pressure' })
    expect(result.rows).to eq([['Blood pressure']])
  end

  it 'raises a clear ExecutionError for a URI operand (no terminology service wired in)' do
    query = 'SELECT o/name/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            "WHERE o/name/value MATCHES {terminology://openehr/some_value_set}"
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect { OpenEHR::AQL.execute(query, dataset) }.to raise_error(OpenEHR::AQL::ExecutionError, /terminology service/)
  end

  it 'raises a clear ExecutionError for a TERMINOLOGY(...) operand (no terminology service wired in)' do
    query = 'SELECT o/name/value FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            "WHERE o/name/value MATCHES {TERMINOLOGY('expand', 'SNOMED-CT', '<10001000>')}"
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect { OpenEHR::AQL.execute(query, dataset) }.to raise_error(OpenEHR::AQL::ExecutionError, /terminology service/)
  end
end

# E14 milestone: a nodePredicate/standardPredicate directly on a
# CONTAINS class expression (e.g. "CONTAINS ELEMENT e2[at0004]" or
# "CONTAINS ELEMENT e2[name/value='Systolic']") already parsed into
# Model::NodePredicate/Model::StandardPredicate (the exact same grammar
# used for archetypePredicate) but ContainsResolver only ever evaluated
# Model::ArchetypePredicate, raising for anything else. Reuses the same
# PathEvaluator.navigate/PredicateEvaluator.compare machinery the E10
# EHR-root predicate already established.
describe 'OpenEHR::AQL.execute (E14: CONTAINS node/standard predicates)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:blood_pressure) { builder.blood_pressure_composition(systolic: 150, diastolic: 85) }

  it 'matches CONTAINS ELEMENT e[atNNNN] by node id' do
    query = 'SELECT e2/value/magnitude FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            'CONTAINS ELEMENT e2[at0004]'
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([[150]])
  end

  it 'excludes a node id that does not match' do
    query = 'SELECT e2/value/magnitude FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            'CONTAINS ELEMENT e2[at9999]'
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([])
  end

  it 'matches CONTAINS ELEMENT e[atNNNN, \'Name\'] by node id and name together' do
    query = "SELECT e2/value/magnitude FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o " \
            "CONTAINS ELEMENT e2[at0004, 'Systolic']"
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([[150]])
  end

  it 'excludes a node id whose name does not match' do
    query = "SELECT e2/value/magnitude FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o " \
            "CONTAINS ELEMENT e2[at0004, 'Wrong name']"
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([])
  end

  it 'matches CONTAINS ELEMENT e[name/value=\'X\'] via a standardPredicate' do
    query = "SELECT e2/value/magnitude FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o " \
            "CONTAINS ELEMENT e2[name/value='Diastolic']"
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([[85]])
  end

  it 'combines node and standard predicates with AND' do
    query = "SELECT e2/value/magnitude FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o " \
            "CONTAINS ELEMENT e2[at0004 AND name/value='Systolic']"
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([[150]])
  end

  it 'combines node predicates with OR' do
    query = 'SELECT e2/value/magnitude FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o ' \
            'CONTAINS ELEMENT e2[at0004 OR at0005] ORDER BY e2/value/magnitude'
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([[85], [150]])
  end
end

# E15 milestone: a SELECT list mixing a plain (non-aggregate) column with
# an aggregate column (e.g. "SELECT o/name/value, COUNT(o) FROM ...")
# used to raise unconditionally ("mixing aggregate and non-aggregate
# SELECT columns is not yet supported"). Implemented as an implicit
# GROUP BY over every non-aggregate column's value (the standard SQL
# reading when a query mixes aggregate and non-aggregate columns without
# an explicit GROUP BY) - zero surviving bindings therefore produces zero
# groups/rows, same as SQL, not one row of aggregate defaults (that stays
# the all-aggregate-columns behaviour, unchanged).
describe 'OpenEHR::AQL.execute (E15: mixed aggregate/non-aggregate SELECT)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:blood_pressure_a) { builder.blood_pressure_composition(systolic: 150, diastolic: 85) }
  let(:blood_pressure_b) { builder.blood_pressure_composition(systolic: 130, diastolic: 80) }
  let(:body_temperature) { builder.body_temperature_composition }

  it 'groups by the non-aggregate column and counts each group' do
    query = 'SELECT o/name/value, COUNT(o) FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o'
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure_a, blood_pressure_b, body_temperature])
    result = OpenEHR::AQL.execute(query, dataset)
    expect(result.rows).to contain_exactly(['Blood pressure', 2], ['Body temperature', 1])
  end

  it 'produces zero rows (zero groups) when nothing survives WHERE, unlike the all-aggregate case' do
    query = "SELECT o/name/value, COUNT(o) FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o " \
            "WHERE o/name/value = 'nonexistent'"
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure_a])
    expect(OpenEHR::AQL.execute(query, dataset).rows).to eq([])
  end

  it 'supports multiple aggregate columns alongside the grouping column' do
    query = 'SELECT o/name/value, COUNT(o), MAX(e2/value/magnitude) ' \
            'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o CONTAINS ELEMENT e2[at0004]'
    dataset = OpenEHR::AQL::Dataset.of_compositions([blood_pressure_a, blood_pressure_b])
    result = OpenEHR::AQL.execute(query, dataset)
    expect(result.rows).to eq([['Blood pressure', 2, 150]])
  end
end

# Issue #60, resolution shape (a) bug: an archetype predicate's name value
# ("[archetype_id, 'name']") was dropped both when a SELECT/WHERE path
# segment was turned into PATHABLE path text (PathEvaluator) and when a
# CONTAINS class expression was matched (ContainsResolver), so a template
# that embeds one archetype twice under one parent and tells the two apart
# by name fanned out (SELECT/WHERE) or silently bound every sibling
# (CONTAINS). Written red-first against master 96eb4e2.
describe 'OpenEHR::AQL.execute (#60: archetype predicate name value)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:composition) { builder.repeated_cluster_composition(names: %w[Referring Receiving]) }
  let(:dataset) { OpenEHR::AQL::Dataset.of_compositions([composition]) }
  let(:from) { 'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o' }
  let(:tree) { 'o/data[at0001]/events[at0006]/data[at0003]' }
  let(:cluster_id) { 'openEHR-EHR-CLUSTER.zz_invented_party.v1' }

  it "SELECT: items[archetype_id, 'name'] picks one of two same-archetype siblings" do
    result = OpenEHR::AQL.execute(
      "SELECT #{tree}/items[#{cluster_id}, 'Receiving']/items[at0001]/value/value AS label #{from}", dataset
    )
    expect(result.rows).to eq([['Receiving value']])
  end

  it 'WHERE: a comparison over the same named path filters rows' do
    query = "SELECT c/name/value #{from} " \
            "WHERE #{tree}/items[#{cluster_id}, 'Receiving']/items[at0001]/value/value = "
    expect(OpenEHR::AQL.execute("#{query}'Receiving value'", dataset).rows).to eq([['Encounter']])
    expect(OpenEHR::AQL.execute("#{query}'Referring value'", dataset).rows).to eq([])
  end

  it "CONTAINS: CLUSTER k[archetype_id, 'name'] binds only the node whose name matches" do
    result = OpenEHR::AQL.execute(
      "SELECT k/items[at0001]/value/value #{from} CONTAINS CLUSTER k[#{cluster_id}, 'Receiving']", dataset
    )
    expect(result.rows).to eq([['Receiving value']])
  end

  it 'raises ExecutionError (not yet supported) for a $parameter name value in a path' do
    query = "SELECT #{tree}/items[#{cluster_id}, $name]/items[at0001]/value/value #{from}"
    expect { OpenEHR::AQL.execute(query, dataset, params: { name: 'Receiving' }).rows }
      .to raise_error(OpenEHR::AQL::ExecutionError, /archetype predicate value yet/)
  end

  it 'raises ExecutionError (not yet supported) for a $parameter name value in CONTAINS' do
    query = "SELECT k/name/value #{from} CONTAINS CLUSTER k[#{cluster_id}, $name]"
    expect { OpenEHR::AQL.execute(query, dataset, params: { name: 'Receiving' }).rows }
      .to raise_error(OpenEHR::AQL::ExecutionError, /archetype predicate value yet/)
  end

  it 'names the archetype predicate readably in the fan-out error' do
    query = "SELECT #{tree}/items[#{cluster_id}]/items[at0001]/value/value #{from}"
    expect { OpenEHR::AQL.execute(query, dataset).rows }
      .to raise_error(OpenEHR::AQL::ExecutionError, /items\[#{Regexp.escape(cluster_id)}\]" matched 2 items/)
  end

  it 'names the archetype predicate with its name value in the fan-out error' do
    query = "SELECT #{tree}/items[#{cluster_id}, 'Receiving']/items[at0001]/value/value #{from}"
    twins = builder.repeated_cluster_composition(names: %w[Receiving Receiving])
    expect { OpenEHR::AQL.execute(query, OpenEHR::AQL::Dataset.of_compositions([twins])).rows }
      .to raise_error(OpenEHR::AQL::ExecutionError, /items\[#{Regexp.escape(cluster_id)}, 'Receiving'\]" matched 2 items/)
  end

  # regression pin: already true on master before the fix - a name-less
  # archetype predicate keeps matching by archetype id alone. Red is not
  # achievable for this example.
  it 'keeps matching a name-less archetype predicate by archetype id alone (regression pin)' do
    result = OpenEHR::AQL.execute("SELECT k/name/value #{from} CONTAINS CLUSTER k[#{cluster_id}]", dataset)
    expect(result.rows).to eq([['Referring'], ['Receiving']])
  end
end

# Issue #48, resolution shape (a) bug: EVENT.time was unreachable from an
# AQL path. Event declares only path_attribute :data, :state, and "time"
# was not in PathEvaluator::ALLOWED_TERMINAL_HOPS, so the hop failed both
# navigation routes and raised 'unsupported path attribute "time"'.
# Written red-first against master 0ef5b33.
describe 'OpenEHR::AQL.execute (#48: EVENT.time hop)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:from) { 'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o' }
  let(:time_path) { 'o/data[at0001]/events[at0006]/time/value' }

  def composition_at(start_time, systolic)
    builder.blood_pressure_composition(systolic: systolic, diastolic: 80, start_time: start_time)
  end

  it 'SELECT: events[...]/time/value returns the event time' do
    dataset = OpenEHR::AQL::Dataset.of_compositions([composition_at('2026-03-01T09:30:00+09:00', 120)])
    result = OpenEHR::AQL.execute("SELECT #{time_path} AS measured_at #{from}", dataset)

    expect(result.columns).to eq(['measured_at'])
    expect(result.rows).to eq([['2026-03-01T09:30:00+09:00']])
  end

  # The comparison is the engine's ordinary String comparison of ISO8601
  # text (lexicographic), not a parsed-instant comparison: it orders
  # correctly only when both sides use the same format and UTC offset.
  it 'WHERE: a half-open time/value range (>= lower AND < upper) keeps only the in-range rows' do
    dataset = OpenEHR::AQL::Dataset.of_compositions(
      [composition_at('2025-12-31T23:59:59', 110), composition_at('2026-01-01T00:00:00', 120),
       composition_at('2026-06-30T23:59:59', 130), composition_at('2026-07-01T00:00:00', 140)]
    )
    result = OpenEHR::AQL.execute(
      "SELECT o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude #{from} " \
      "WHERE #{time_path} >= '2026-01-01T00:00:00' AND #{time_path} < '2026-07-01T00:00:00'", dataset
    )

    expect(result.rows).to contain_exactly([120], [130])
  end
end

# Issue #49, resolution shape (b) enhancement, minimal form (Option A):
# "defining_code" and "code_string" join
# PathEvaluator::ALLOWED_TERMINAL_HOPS, so a DV_CODED_TEXT's code - not
# only its display label - is reachable from a path. Written red-first
# against master d5e3a90.
describe 'OpenEHR::AQL.execute (#49: defining_code / code_string hops)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:from) { 'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o' }
  let(:coded) { 'o/data[at0001]/events[at0006]/data[at0003]/items[at0007]/value' }
  let(:dataset) do
    OpenEHR::AQL::Dataset.of_compositions(
      [builder.coded_value_composition(label: 'Suspected', code: 'at9074'),
       builder.coded_value_composition(label: 'Probable', code: 'at9075'),
       builder.coded_value_composition(label: 'Confirmed', code: 'at9076')]
    )
  end

  it 'SELECT: value/defining_code/code_string returns the code, not the label' do
    result = OpenEHR::AQL.execute("SELECT #{coded}/defining_code/code_string AS code #{from}", dataset)
    expect(result.rows).to eq([['at9074'], ['at9075'], ['at9076']])
  end

  it 'WHERE: code_string MATCHES {...} filters rows by code' do
    result = OpenEHR::AQL.execute(
      "SELECT #{coded}/value #{from} WHERE #{coded}/defining_code/code_string MATCHES {'at9074', 'at9075'}", dataset
    )
    expect(result.rows).to eq([['Suspected'], ['Probable']])
  end

  it 'still raises ExecutionError for an attribute outside the whitelist (regression pin)' do
    # regression pin: the whitelist stays a whitelist. encoding is a real
    # public reader on DV_CODED_TEXT, and is still not reachable.
    expect do
      OpenEHR::AQL.execute("SELECT #{coded}/encoding #{from}", dataset)
    end.to raise_error(OpenEHR::AQL::ExecutionError, /unsupported path attribute "encoding" on a .*DvCodedText/)
  end
end

# Issue #70, resolution shape (b) enhancement: archetype_details/template_id
# becomes reachable from a path. The terminal-hop whitelist gains a
# per-type table (TYPED_TERMINAL_HOPS) next to the generic names, and a
# whitelisted name the current value does not have now raises the
# engine's own ExecutionError instead of leaking NoMethodError. Written
# red-first against master 86f9f8a.
describe 'OpenEHR::AQL.execute (#70: archetype_details/template_id, per-type terminal hops)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:from) { 'FROM EHR e CONTAINS COMPOSITION c' }
  let(:plain) { builder.blood_pressure_composition(systolic: 120, diastolic: 80) }
  let(:templated) do
    builder.templated(builder.blood_pressure_composition(systolic: 150, diastolic: 95), template_id: 'zz_invented_template.v0')
  end
  let(:dataset) { OpenEHR::AQL::Dataset.of_compositions([templated, plain]) }

  it 'SELECT: c/archetype_details/template_id/value returns the template id' do
    result = OpenEHR::AQL.execute("SELECT c/archetype_details/template_id/value AS template #{from}",
                                  OpenEHR::AQL::Dataset.of_compositions([templated]))
    expect(result.rows).to eq([['zz_invented_template.v0']])
  end

  it 'returns a null column, not an exception, for a COMPOSITION without archetype_details' do
    result = OpenEHR::AQL.execute("SELECT c/archetype_details/template_id/value #{from}", dataset)
    expect(result.rows).to eq([['zz_invented_template.v0'], [nil]])
  end

  it 'WHERE: filters compositions by template id' do
    result = OpenEHR::AQL.execute(
      "SELECT c/name/value #{from} CONTAINS OBSERVATION o " \
      "WHERE c/archetype_details/template_id/value = 'zz_invented_template.v0'", dataset
    )
    expect(result.rows).to eq([['Encounter']])
  end

  it 'SELECT: c/archetype_details/archetype_id/value returns the root archetype id' do
    result = OpenEHR::AQL.execute("SELECT c/archetype_details/archetype_id/value #{from}",
                                  OpenEHR::AQL::Dataset.of_compositions([templated]))
    expect(result.rows).to eq([['openEHR-EHR-COMPOSITION.encounter.v1']])
  end

  it 'does not make a typed hop reachable on another type (regression pin)' do
    # regression pin: this already raised before #70 (the name was in no
    # list); it pins that the per-type table stays per type.
    expect do
      OpenEHR::AQL.execute("SELECT c/name/template_id #{from}", dataset)
    end.to raise_error(OpenEHR::AQL::ExecutionError, /unsupported path attribute "template_id" on a .*DvText/)
  end

  it 'raises ExecutionError, not NoMethodError, for a generic hop the value does not have' do
    expect do
      OpenEHR::AQL.execute("SELECT c/name/magnitude #{from}", dataset)
    end.to raise_error(OpenEHR::AQL::ExecutionError, /unsupported path attribute "magnitude" on a .*DvText/)
  end

  it 'still raises ExecutionError for a name in neither list (regression pin)' do
    # regression pin: composer is a real public reader on COMPOSITION and
    # is still not reachable.
    expect do
      OpenEHR::AQL.execute("SELECT c/composer #{from}", dataset)
    end.to raise_error(OpenEHR::AQL::ExecutionError, /unsupported path attribute "composer" on a .*Composition/)
  end
end
