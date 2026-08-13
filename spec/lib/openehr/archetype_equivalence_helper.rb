# Shared structural equivalence assertion for round-trip specs (ADL <->
# AOM <-> XML). Two Archetype instances built through different
# parser/serializer paths should agree on identity, structure, and
# validity even if they're not #== (Archetype has no value equality).
def expect_equivalent_archetypes(original, reparsed)
  expect(reparsed.archetype_id.value).to eq(original.archetype_id.value)
  expect(reparsed.physical_paths.sort).to eq(original.physical_paths.sort)
  expect(reparsed.node_ids_valid?).to be true
  expect(reparsed.is_valid?).to be true
  expect(reparsed.ontology.term_definitions.keys.sort).to eq(original.ontology.term_definitions.keys.sort)
end
