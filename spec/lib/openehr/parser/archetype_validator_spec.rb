require File.dirname(__FILE__) + '/../../../spec_helper'

describe OpenEHR::Parser::ArchetypeValidator do
  let(:archetype_id) { double('archetype_id', :value => 'openEHR-EHR-CLUSTER.test.v1', :rm_entity => 'CLUSTER') }
  let(:definition) { double('definition', :rm_type_name => 'CLUSTER') }
  let(:ontology) { double('ontology', :term_codes => ['at0000']) }
  let(:archetype) do
    double('archetype',
          :archetype_id => archetype_id,
          :concept => 'at0000',
          :definition => definition,
          :ontology => ontology,
          :node_ids_valid? => true,
          :constraint_references_valid? => true,
          :internal_references_valid? => true,
          :physical_paths => ['/', '/items[at0001]'])
  end

  describe '#valid?' do
    it 'is true when every rule passes' do
      expect(described_class.new(archetype)).to be_valid
    end

    it 'is false when any rule fails' do
      allow(archetype).to receive(:node_ids_valid?).and_return(false)
      expect(described_class.new(archetype)).not_to be_valid
    end
  end

  describe '#errors' do
    it 'is empty when every rule passes' do
      expect(described_class.new(archetype).errors).to be_empty
    end

    it 'includes VARCN when the concept is not defined in the ontology term codes' do
      allow(archetype).to receive(:concept).and_return('at9999')
      errors = described_class.new(archetype).errors
      expect(errors).to include(an_instance_of(OpenEHR::Parser::Exception::Validation::VARCN))
    end

    it 'includes VARDT when the definition rm_type_name does not match the archetype id rm_entity' do
      allow(archetype).to receive(:definition).and_return(double('definition', :rm_type_name => 'OBSERVATION'))
      errors = described_class.new(archetype).errors
      expect(errors).to include(an_instance_of(OpenEHR::Parser::Exception::Validation::VARDT))
    end

    it 'does not include VARDT when rm_type_name and rm_entity only differ in casing' do
      allow(archetype).to receive(:definition).and_return(double('definition', :rm_type_name => 'Cluster'))
      allow(archetype_id).to receive(:rm_entity).and_return('cluster')
      errors = described_class.new(archetype).errors
      expect(errors).not_to include(an_instance_of(OpenEHR::Parser::Exception::Validation::VARDT))
    end

    it 'includes VATDF when node_ids_valid? is false' do
      allow(archetype).to receive(:node_ids_valid?).and_return(false)
      errors = described_class.new(archetype).errors
      expect(errors).to include(an_instance_of(OpenEHR::Parser::Exception::Validation::VATDF))
    end

    it 'includes VACDF when constraint_references_valid? is false' do
      allow(archetype).to receive(:constraint_references_valid?).and_return(false)
      errors = described_class.new(archetype).errors
      expect(errors).to include(an_instance_of(OpenEHR::Parser::Exception::Validation::VACDF))
    end

    it 'includes VDFPT when internal_references_valid? is false' do
      allow(archetype).to receive(:internal_references_valid?).and_return(false)
      errors = described_class.new(archetype).errors
      expect(errors).to include(an_instance_of(OpenEHR::Parser::Exception::Validation::VDFPT))
    end

    it 'includes VDFPT when a physical path is not syntactically valid' do
      allow(archetype).to receive(:physical_paths).and_return(['not a valid path'])
      errors = described_class.new(archetype).errors
      expect(errors).to include(an_instance_of(OpenEHR::Parser::Exception::Validation::VDFPT))
    end
  end

  describe '#validate!' do
    it 'does not raise when the archetype is valid' do
      expect { described_class.new(archetype).validate! }.not_to raise_error
    end

    it 'raises the first violated rule' do
      allow(archetype).to receive(:node_ids_valid?).and_return(false)
      expect { described_class.new(archetype).validate! }
        .to raise_error(OpenEHR::Parser::Exception::Validation::VATDF)
    end
  end

  describe '#validate_instance' do
    it 'is empty when the rm instance conforms to the archetype definition' do
      rm_root = double('rm root')
      allow(definition).to receive(:valid_value?).with(rm_root).and_return(true)

      expect(described_class.new(archetype).validate_instance(rm_root)).to be_empty
    end

    it 'reports a path-annotated failure when the rm instance does not conform' do
      rm_root = double('rm root')
      allow(definition).to receive(:valid_value?).with(rm_root).and_return(false)
      allow(definition).to receive(:find_violation).with(rm_root).and_return([definition, rm_root])
      allow(rm_root).to receive(:path_of_item).with(rm_root).and_return('/')

      result = described_class.new(archetype).validate_instance(rm_root)
      expect(result.size).to eq(1)
      expect(result.first.path).to eq('/')
      expect(result.first).to be_an_instance_of OpenEHR::Parser::Exception::Validation::InstanceNonConformant
    end

    it 'falls back to an unresolved path when the rm root is not Pathable' do
      rm_root = double('rm root')
      allow(definition).to receive(:valid_value?).with(rm_root).and_return(false)
      allow(definition).to receive(:find_violation).with(rm_root).and_return([definition, rm_root])

      result = described_class.new(archetype).validate_instance(rm_root)
      expect(result.first.path).to be_nil
    end
  end
end
