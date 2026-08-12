require File.dirname(__FILE__) + '/../../../spec_helper'

# Acceptance test for the Factory.params Array-recursion fix
# (lib/openehr/rm/factory.rb): a composition rebuilt from canonical
# JSON via OpenEHR::RM::CompositionFactory.create_from_json - the
# integration path this gem's own README recommends for AQL Dataset -
# must be fully traversable by CONTAINS. Before the fix, content/events/
# items etc. were left as raw Hashes and ContainsResolver's subtree walk
# silently skipped them (`next unless node.is_a?(Pathable)`), so these
# queries returned zero rows with no exception anywhere.
describe 'OpenEHR::AQL over a JSON-round-tripped composition' do
  let(:json) { File.read(File.expand_path('../../../fixtures/health_summary_composition.json', __dir__)) }
  let(:composition) { OpenEHR::RM::CompositionFactory.create_from_json(json) }
  let(:dataset) { OpenEHR::AQL::Dataset.of_compositions([composition], ehr_id: 'ehr-1') }

  it 'CONTAINS reaches the OBSERVATIONs rebuilt from JSON' do
    result = OpenEHR::AQL.execute('SELECT o FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o', dataset)

    expect(result.rows).not_to be_empty
    expect(result.rows.map { |row| row.first.archetype_node_id })
      .to eq(%w[openEHR-EHR-OBSERVATION.story.v1 openEHR-EHR-OBSERVATION.temperature.v1])
  end

  it 'CONTAINS reaches the deeply nested CLUSTER by archetype predicate' do
    result = OpenEHR::AQL.execute(
      'SELECT cl FROM EHR e CONTAINS COMPOSITION c ' \
      'CONTAINS CLUSTER cl [openEHR-EHR-CLUSTER.symptom_sign.v1]', dataset
    )

    expect(result.rows.size).to eq(1)
    expect(result.rows.first.first.items.first.value.value).to eq('咳、鼻水')
  end

  it 'SELECT paths walk into the JSON-rebuilt tree' do
    result = OpenEHR::AQL.execute(
      'SELECT c/name FROM EHR e CONTAINS COMPOSITION c', dataset
    )

    expect(result.rows.first.first.value).to eq('Health summary')
  end
end
