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
