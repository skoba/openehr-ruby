require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

# #50 — resolution shape (a) bug: on master this example went red with
# "Invalid ADL" (V_ARCHETYPE_ID required a non-zero leading version digit,
# so every CKM ".v0" development archetype was rejected), then green once
# the grammar accepts ".v" [0-9]+ like the RM ArchetypeID already does.
#
# Fixture kind: real — CKM export used as-is (provenance in
# spec/fixtures/ckm/README.md).
describe ADLParser do
  ckm_fixture_dir = File.expand_path('../../../fixtures/ckm', __dir__)

  context 'a CKM development archetype whose id ends in .v0 (#50)' do
    let(:adl_file) do
      File.join(ckm_fixture_dir,
                'openEHR-EHR-EVALUATION.infectious_disease_summary.v0.adl')
    end

    it 'parses instead of raising Invalid ADL' do
      expect { ADLParser.new(adl_file).parse }.not_to raise_error
    end

    it 'exposes the v0 archetype id' do
      archetype = ADLParser.new(adl_file).parse
      expect(archetype.archetype_id.value)
        .to eq('openEHR-EHR-EVALUATION.infectious_disease_summary.v0')
      expect(archetype.archetype_id.version_id).to eq('v0')
    end
  end

  context 'a published archetype id (.v1) — regression pin' do
    # Regression pin: this was already true before the #50 fix; it guards
    # the widened version class against accidentally losing .v1.
    it 'still parses' do
      archetype = adl14_archetype('openEHR-EHR-CLUSTER.anatomical_location.v1.adl')
      expect(archetype.archetype_id.version_id).to eq('v1')
    end
  end
end
