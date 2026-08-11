require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::AssumedLibraryTypes
include OpenEHR::RM::DataTypes::Quantity
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataStructures::ItemStructure::Representation

describe CComplexObject do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    parent = double(CAttribute, :rm_attribute_name => 'event',
                  :path => "/event")
    attribute = CAttribute.new(:rm_attribute_name => 'data')
    attributes = [attribute, attribute, attribute]
    @c_complex_object = CComplexObject.new(:rm_type_name => 'DV_TIME',
                                           :parent => parent,
                                           :node_id => 'at0001',
                                           :occurrences => occurrences,
                                           :attributes => attributes)
  end

  it 'should be an instance of CComplexObject' do
    expect(@c_complex_object).to be_an_instance_of CComplexObject
  end

  context 'attributes' do

    it 'attributes should be assigned properly' do
      expect(@c_complex_object.attributes.size).to be_equal 3
    end

    it 'attributes parent should be assigned properly' do
      expect(@c_complex_object.attributes[0].parent).to eq(@c_complex_object)
    end

    it 'has attribytes when has_attrubite? is true' do
      expect(@c_complex_object.has_attributes?).to be_truthy
    end

    it 'does not have attributes when attributes is nil' do
      @c_complex_object.attributes = nil
      expect(@c_complex_object.has_attributes?).not_to be_truthy
    end

    it 'does not have attributes when attributes are empty' do
      @c_complex_object.attributes = []
      expect(@c_complex_object.has_attributes?).not_to be_truthy
    end
  end
  
  it 'any_allowed should be false when attributes are not empty' do
    expect(@c_complex_object).not_to be_any_allowed
  end


  it 'any_allowed should be true when attributes are nil' do
    @c_complex_object.attributes = nil
    expect(@c_complex_object).to be_any_allowed
  end

  it 'any_allowed should be true when attributes are empty' do
    @c_complex_object.attributes = Set.new
    expect(@c_complex_object).to be_any_allowed
  end

  it 'path should be calculated properly' do
    expect(@c_complex_object.path).to eq('/event[at0001]')
  end

  context 'path' do
    before(:each) do
      @c_complex_object.path = '/event[at0002]'
    end

    it 'should be assigned properly' do
      expect(@c_complex_object.path).to eq('/event[at0002]')
    end
  end

  describe '#valid_value?' do
    let(:mandatory) { Interval.new(:lower => 1, :upper => 1, :lower_included => true, :upper_included => true) }
    let(:optional) { Interval.new(:lower => 0, :upper => 1, :lower_included => true, :upper_included => true) }

    it 'is false when the value is nil' do
      constraint = CComplexObject.new(:rm_type_name => 'DV_COUNT', :occurrences => optional)
      expect(constraint.valid_value?(nil)).to be false
    end

    it 'is false when the value does not conform to rm_type_name' do
      constraint = CComplexObject.new(:rm_type_name => 'DV_COUNT', :occurrences => optional)
      expect(constraint.valid_value?(DvText.new(:value => 'not a count'))).to be false
    end

    it 'is true for any conforming value when any_allowed (no attributes constrained)' do
      constraint = CComplexObject.new(:rm_type_name => 'DV_COUNT', :occurrences => optional)
      expect(constraint.valid_value?(DvCount.new(:magnitude => 5))).to be true
    end

    context 'with a node_id constraint' do
      let(:constraint) do
        CComplexObject.new(:rm_type_name => 'ELEMENT', :node_id => 'at0001', :occurrences => optional)
      end

      it 'is false when archetype_node_id differs' do
        element = Element.new(:archetype_node_id => 'at0002', :name => DvText.new(:value => 'x'))
        expect(constraint.valid_value?(element)).to be false
      end

      it 'is true when archetype_node_id matches' do
        element = Element.new(:archetype_node_id => 'at0001', :name => DvText.new(:value => 'x'))
        expect(constraint.valid_value?(element)).to be true
      end
    end

    context 'with a constrained attribute (DV_COUNT.magnitude via C_INTEGER)' do
      let(:magnitude_attribute) do
        CSingleAttribute.new(:rm_attribute_name => 'magnitude',
                             :existence => mandatory,
                             :children => [CPrimitiveObject.new(:rm_type_name => 'Integer',
                                                                  :occurrences => mandatory,
                                                                  :item => CInteger.new(:range => Interval.new(:lower => 0, :upper => 100)))])
      end
      let(:constraint) do
        CComplexObject.new(:rm_type_name => 'DV_COUNT', :occurrences => optional,
                           :attributes => [magnitude_attribute])
      end

      it 'is true when the attribute value is within range' do
        expect(constraint.valid_value?(DvCount.new(:magnitude => 5))).to be true
      end

      it 'is false when the attribute value is out of range' do
        expect(constraint.valid_value?(DvCount.new(:magnitude => 500))).to be false
      end
    end
  end

  describe '#find_violation' do
    let(:optional) { Interval.new(:lower => 0, :upper => 1, :lower_included => true, :upper_included => true) }
    let(:mandatory) { Interval.new(:lower => 1, :upper => 1, :lower_included => true, :upper_included => true) }

    it 'is nil when the value fully conforms' do
      constraint = CComplexObject.new(:rm_type_name => 'DV_COUNT', :occurrences => optional)
      expect(constraint.find_violation(DvCount.new(:magnitude => 5))).to be_nil
    end

    it 'returns [self, value] when the value itself does not conform' do
      constraint = CComplexObject.new(:rm_type_name => 'DV_COUNT', :occurrences => optional)
      value = DvText.new(:value => 'not a count')
      expect(constraint.find_violation(value)).to eq([constraint, value])
    end

    it 'descends into a failing nested attribute value' do
      magnitude_attribute =
        CSingleAttribute.new(:rm_attribute_name => 'magnitude', :existence => mandatory,
                             :children => [CPrimitiveObject.new(:rm_type_name => 'Integer',
                                                                  :occurrences => mandatory,
                                                                  :item => CInteger.new(:range => Interval.new(:lower => 0, :upper => 100)))])
      constraint = CComplexObject.new(:rm_type_name => 'DV_COUNT', :occurrences => optional,
                                      :attributes => [magnitude_attribute])

      _node, violated_value = constraint.find_violation(DvCount.new(:magnitude => 500))
      expect(violated_value).to eq(500)
    end
  end

  describe '#default_value' do
    let(:mandatory) { Interval.new(:lower => 1, :upper => 1, :lower_included => true, :upper_included => true) }
    let(:optional) { Interval.new(:lower => 0, :upper => 1, :lower_included => true, :upper_included => true) }

    it 'is nil when any_allowed (no attributes to construct from)' do
      constraint = CComplexObject.new(:rm_type_name => 'DV_COUNT', :occurrences => optional)
      expect(constraint.default_value).to be_nil
    end

    it 'is nil when rm_type_name is not a known RM type' do
      attribute = CSingleAttribute.new(:rm_attribute_name => 'magnitude')
      constraint = CComplexObject.new(:rm_type_name => 'NOT_A_REAL_TYPE', :occurrences => optional,
                                      :attributes => [attribute])
      expect(constraint.default_value).to be_nil
    end

    context 'with a mandatory attribute whose primitive has a default_value' do
      let(:magnitude_attribute) do
        CSingleAttribute.new(:rm_attribute_name => 'magnitude', :existence => mandatory,
                             :children => [CPrimitiveObject.new(:rm_type_name => 'Integer',
                                                                  :occurrences => mandatory,
                                                                  :item => CInteger.new(:default_value => 5))])
      end
      let(:constraint) do
        CComplexObject.new(:rm_type_name => 'DV_COUNT', :occurrences => optional,
                           :attributes => [magnitude_attribute])
      end

      it 'builds a minimal RM instance from the mandatory attributes default values' do
        value = constraint.default_value
        expect(value).to be_an_instance_of DvCount
        expect(value.magnitude).to eq(5)
      end
    end

    context 'with a mandatory attribute whose primitive has no default_value' do
      let(:magnitude_attribute) do
        CSingleAttribute.new(:rm_attribute_name => 'magnitude', :existence => mandatory,
                             :children => [CPrimitiveObject.new(:rm_type_name => 'Integer',
                                                                  :occurrences => mandatory,
                                                                  :item => CInteger.new)])
      end
      let(:constraint) do
        CComplexObject.new(:rm_type_name => 'DV_COUNT', :occurrences => optional,
                           :attributes => [magnitude_attribute])
      end

      it 'is nil since the mandatory field cannot be constructed' do
        expect(constraint.default_value).to be_nil
      end
    end

    context 'with a mandatory multiple attribute' do
      let(:text_item) do
        CComplexObject.new(:rm_type_name => 'DV_TEXT', :occurrences => mandatory,
                           :attributes => [CSingleAttribute.new(:rm_attribute_name => 'value',
                                                                :existence => mandatory,
                                                                :children => [CPrimitiveObject.new(:rm_type_name => 'String',
                                                                                                     :occurrences => mandatory,
                                                                                                     :item => CString.new(:default_value => 'line'))])])
      end
      let(:items_attribute) do
        CMultipleAttribute.new(:rm_attribute_name => 'items', :existence => mandatory,
                               :cardinality => Cardinality.new(:interval => Interval.new(:lower => 2, :upper => 2,
                                                                                            :lower_included => true,
                                                                                            :upper_included => true)),
                               :children => [text_item])
      end
      let(:constraint) do
        CComplexObject.new(:rm_type_name => 'DV_PARAGRAPH', :occurrences => optional,
                           :attributes => [items_attribute])
      end

      it 'builds the minimum cardinality worth of items from the first child alternative' do
        value = constraint.default_value
        expect(value.items.size).to eq(2)
        expect(value.items.map(&:value)).to eq(['line', 'line'])
      end
    end
  end
end
