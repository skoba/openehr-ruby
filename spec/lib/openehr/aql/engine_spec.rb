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
