require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

# #51 — resolution shape (a) bug: on master these examples went red with
# "Invalid ADL" (rule archetype_slot had no alternative for a slot block
# with neither include nor exclude, which the CKM emits for "any
# archetype" slots), then green once the grammar gained an empty-block
# alternative building an ArchetypeSlot with nil includes/excludes — the
# state ArchetypeSlot#any_allowed? already defines.
#
# Fixture kind: real — CKM export used as-is (provenance in
# spec/fixtures/ckm/README.md). openEHR-EHR-OBSERVATION.body_temperature.v2
# (cid 1013.1.2796, CLUSTER[at0062] "Extension") carries the same construct
# and is the issue's second witness; person.v1 is the smaller of the two.
describe ADLParser do
  let(:ckm_fixture_dir) { File.expand_path('../../../fixtures/ckm', __dir__) }

  context 'a CKM archetype with an empty "any archetype" slot (#51)' do
    let(:adl_file) do
      File.join(ckm_fixture_dir, 'openEHR-EHR-CLUSTER.person.v1.adl')
    end
    let(:archetype) { ADLParser.new(adl_file).parse }
    let(:slots) do
      archetype.definition.attributes
               .find { |a| a.rm_attribute_name == 'items' }.children
               .select { |c| c.is_a?(OpenEHR::AM::Archetype::ConstraintModel::ArchetypeSlot) }
    end
    let(:empty_slot) { slots.find { |s| s.node_id == 'at0008' } }

    it 'parses instead of raising Invalid ADL' do
      expect { archetype }.not_to raise_error
    end

    it 'yields an ArchetypeSlot with neither includes nor excludes' do
      expect(empty_slot).to be_an_instance_of(OpenEHR::AM::Archetype::ConstraintModel::ArchetypeSlot)
      expect(empty_slot.includes).to be_nil
      expect(empty_slot.excludes).to be_nil
      expect(empty_slot.any_allowed?).to be true
    end

    it 'keeps the slot head (rm type, occurrences)' do
      expect(empty_slot.rm_type_name).to eq('CLUSTER')
      expect(empty_slot.occurrences.lower).to eq(0)
      expect(empty_slot.occurrences.upper_unbounded?).to be true
    end

    it 'leaves a sibling slot with an include assertion intact' do
      # Regression pin: the include-only alternative was already accepted
      # before the #51 fix; this guards it against the new alternative.
      with_include = slots.find { |s| s.node_id == 'at0002' }
      expect(with_include.includes).not_to be_empty
      expect(with_include.excludes).to be_nil
    end

    it 'reaches the empty slot through physical_paths' do
      expect(archetype.physical_paths).to include(empty_slot.path)
    end

    it 'is accepted by the ADL and XML serializers' do
      expect { OpenEHR::Serializer::ADLSerializer.new(archetype).merge }.not_to raise_error
      expect { OpenEHR::Serializer::XMLSerializer.new(archetype).merge }.not_to raise_error
    end
  end
end
