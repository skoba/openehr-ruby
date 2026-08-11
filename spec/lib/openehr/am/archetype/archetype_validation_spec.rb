require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes
include OpenEHR::RM::Support::Identification

describe Archetype do
  let(:mandatory) { Interval.new(:lower => 1, :upper => 1, :lower_included => true, :upper_included => true) }
  let(:default_ontology) { double('ontology', :term_codes => ['at0000'], :constraint_codes => nil, :specialisation_depth => nil) }
  let(:any_allowed_cluster) { CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory) }

  def build_archetype(definition:, ontology: default_ontology, archetype_id: nil, parent_archetype_id: nil)
    original_language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(
      :terminology_id => TerminologyID.new(:value => 'ISO_639-1'), :code_string => 'en')
    Archetype.new(:archetype_id => archetype_id || ArchetypeID.new(:value => 'openEHR-EHR-CLUSTER.test.v1'),
                 :concept => 'at0000', :definition => definition, :ontology => ontology,
                 :original_language => original_language,
                 :parent_archetype_id => parent_archetype_id)
  end

  describe '#physical_paths' do
    it 'lists every node path reachable from the definition, without duplicates' do
      element = CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'at0001', :occurrences => mandatory)
      items = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory, :children => [element])
      cluster = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory, :attributes => [items])

      expect(build_archetype(:definition => cluster).physical_paths).to eq(['/', '/items', '/items[at0001]'])
    end

    it 'de-duplicates a node whose sole child adds no further path segment' do
      dv_text = CComplexObject.new(:rm_type_name => 'DV_TEXT', :occurrences => mandatory)
      value = CSingleAttribute.new(:rm_attribute_name => 'value', :existence => mandatory, :children => [dv_text])
      element = CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'at0001', :occurrences => mandatory,
                                   :attributes => [value])
      items = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory, :children => [element])
      cluster = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory,
                                   :attributes => [items])

      expect(build_archetype(:definition => cluster).physical_paths)
        .to eq(['/', '/items', '/items[at0001]', '/items[at0001]/value'])
    end
  end

  describe '#logical_paths' do
    it 'replaces at-code predicates with the ontology term text for the given language' do
      element = CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'at0001', :occurrences => mandatory)
      items = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory, :children => [element])
      cluster = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory,
                                   :attributes => [items])
      term = double('term', :items => {'text' => 'Body site name'})
      ontology = double('ontology', :term_definition => term)

      expect(build_archetype(:definition => cluster, :ontology => ontology).logical_paths('en'))
        .to eq(['/', '/items', '/items[Body site name]'])
    end
  end

  describe '#specialisation_depth' do
    it 'uses the ontology-provided depth when set' do
      ontology = double('ontology', :specialisation_depth => 2)
      archetype = build_archetype(:definition => any_allowed_cluster, :ontology => ontology)
      expect(archetype.specialisation_depth).to eq(2)
    end

    it 'falls back to 1 when archetype_id carries a specialisation suffix and the ontology has no depth' do
      id = ArchetypeID.new(:value => 'openEHR-EHR-CLUSTER.test-special.v1')
      archetype = build_archetype(:definition => any_allowed_cluster, :archetype_id => id)
      expect(archetype.specialisation_depth).to eq(1)
    end

    it 'falls back to 0 when there is no specialisation suffix and no ontology depth' do
      expect(build_archetype(:definition => any_allowed_cluster).specialisation_depth).to eq(0)
    end
  end

  describe '#is_specialised?' do
    it 'is true when the archetype has a parent_archetype_id' do
      parent = ArchetypeID.new(:value => 'openEHR-EHR-CLUSTER.parent.v1')
      archetype = build_archetype(:definition => any_allowed_cluster, :parent_archetype_id => parent)
      expect(archetype.is_specialised?).to be true
    end

    it 'is false when there is no parent_archetype_id' do
      expect(build_archetype(:definition => any_allowed_cluster).is_specialised?).to be false
    end
  end

  describe '#node_ids_valid?' do
    let(:element) { CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'at0001', :occurrences => mandatory) }
    let(:items) { CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory, :children => [element]) }
    let(:cluster) { CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory, :attributes => [items]) }

    it 'is true when every node_id is syntactically valid and defined in the ontology' do
      ontology = double('ontology', :term_codes => ['at0000', 'at0001'])
      expect(build_archetype(:definition => cluster, :ontology => ontology).node_ids_valid?).to be true
    end

    it 'is false when a node_id is not defined in the ontology term codes' do
      ontology = double('ontology', :term_codes => ['at0000'])
      expect(build_archetype(:definition => cluster, :ontology => ontology).node_ids_valid?).to be false
    end

    it 'is false when a node_id is not a syntactically valid at/ac/id-code' do
      bad_element = CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'bad_id', :occurrences => mandatory)
      bad_items = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory, :children => [bad_element])
      bad_cluster = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory,
                                       :attributes => [bad_items])
      ontology = double('ontology', :term_codes => ['at0000', 'bad_id'])
      expect(build_archetype(:definition => bad_cluster, :ontology => ontology).node_ids_valid?).to be false
    end

    it 'keeps the old typo-named method as a deprecated alias' do
      ontology = double('ontology', :term_codes => ['at0000', 'at0001'])
      archetype = build_archetype(:definition => cluster, :ontology => ontology)
      expect(archetype.node_ids_vaild?).to eq(archetype.node_ids_valid?)
    end
  end

  describe '#constraint_references_valid?' do
    it 'is true when there are no constraint references' do
      expect(build_archetype(:definition => any_allowed_cluster).constraint_references_valid?).to be true
    end

    it 'is true when every ConstraintRef reference exists in the ontology constraint codes' do
      ref = ConstraintRef.new(:rm_type_name => 'DV_TEXT', :occurrences => mandatory, :reference => 'ac0001')
      value = CSingleAttribute.new(:rm_attribute_name => 'value', :existence => mandatory, :children => [ref])
      element = CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'at0001', :occurrences => mandatory,
                                   :attributes => [value])
      items = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory, :children => [element])
      cluster = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory,
                                   :attributes => [items])
      ontology = double('ontology', :term_codes => ['at0000', 'at0001'], :constraint_codes => ['ac0001'])

      expect(build_archetype(:definition => cluster, :ontology => ontology).constraint_references_valid?).to be true
    end

    it 'is false when a ConstraintRef reference does not exist in the ontology constraint codes' do
      ref = ConstraintRef.new(:rm_type_name => 'DV_TEXT', :occurrences => mandatory, :reference => 'ac0099')
      value = CSingleAttribute.new(:rm_attribute_name => 'value', :existence => mandatory, :children => [ref])
      element = CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'at0001', :occurrences => mandatory,
                                   :attributes => [value])
      items = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory, :children => [element])
      cluster = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory,
                                   :attributes => [items])
      ontology = double('ontology', :term_codes => ['at0000', 'at0001'], :constraint_codes => ['ac0001'])

      expect(build_archetype(:definition => cluster, :ontology => ontology).constraint_references_valid?).to be false
    end
  end

  describe '#internal_references_valid?' do
    it 'is true when there are no internal references' do
      expect(build_archetype(:definition => any_allowed_cluster).internal_references_valid?).to be true
    end

    it 'is true when every internal ref target_path exists in physical_paths' do
      target = CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'at0001', :occurrences => mandatory)
      ref = ArchetypeInternalRef.new(:rm_type_name => 'ELEMENT', :occurrences => mandatory,
                                     :target_path => '/items[at0001]')
      items = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory, :children => [target, ref])
      cluster = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory,
                                   :attributes => [items])
      ontology = double('ontology', :term_codes => ['at0000', 'at0001'])

      expect(build_archetype(:definition => cluster, :ontology => ontology).internal_references_valid?).to be true
    end

    it 'is false when a target_path does not exist anywhere in the definition' do
      ref = ArchetypeInternalRef.new(:rm_type_name => 'ELEMENT', :occurrences => mandatory,
                                     :target_path => '/items[at0099]')
      items = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory, :children => [ref])
      cluster = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory,
                                   :attributes => [items])

      expect(build_archetype(:definition => cluster).internal_references_valid?).to be false
    end
  end

  describe '#previous_version' do
    it 'is nil - this gem does not parse ADL revision history' do
      expect(build_archetype(:definition => any_allowed_cluster).previous_version).to be_nil
    end
  end

  describe '#is_valid?' do
    it 'is true when node_ids, constraint references and internal references are all valid' do
      expect(build_archetype(:definition => any_allowed_cluster).is_valid?).to be true
    end

    it 'is false when node_ids_valid? fails' do
      bad_element = CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'bad_id', :occurrences => mandatory)
      bad_items = CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory, :children => [bad_element])
      bad_cluster = CComplexObject.new(:rm_type_name => 'CLUSTER', :node_id => 'at0000', :occurrences => mandatory,
                                       :attributes => [bad_items])
      ontology = double('ontology', :term_codes => ['at0000', 'bad_id'], :constraint_codes => nil)

      expect(build_archetype(:definition => bad_cluster, :ontology => ontology).is_valid?).to be false
    end
  end
end
