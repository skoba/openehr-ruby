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
