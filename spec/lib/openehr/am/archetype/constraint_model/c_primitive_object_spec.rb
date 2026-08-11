describe OpenEHR::AM::Archetype::ConstraintModel::CPrimitiveObject do
  before(:each) do
    interval = OpenEHR::AssumedLibraryTypes::Interval.new(:lower => 0, :upper => 1)
    item = double(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CPrimitive, :node_id => 'at0001')
    @c_primitive_object = OpenEHR::AM::Archetype::ConstraintModel::CPrimitiveObject.new(:path => 'event/test',
                                               :rm_type_name => 'DV_TEXT',
                                               :node_id => 'ac0001',
                                               :occurrences => interval,
                                               :item => item)
  end

  it 'should be an instance of CPrimitiveObject' do
    expect(@c_primitive_object).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CPrimitiveObject
  end

  it 'item should be assigned properly' do
    expect(@c_primitive_object.item.node_id).to eq('at0001')
  end

  it 'should allowed any' do
    expect(@c_primitive_object).not_to be_any_allowed
  end

  it 'should not any allowed' do
    @c_primitive_object.item = nil
    expect(@c_primitive_object).to be_any_allowed
  end

  it 'should not define the malformed delegated method literally named any_allowed?,' do
    expect(@c_primitive_object).not_to respond_to(:'any_allowed?,')
  end

  it 'should delegate assumed_value to item' do
    item = OpenEHR::AM::Archetype::ConstraintModel::Primitive::CBoolean.new(:true_valid => true, :false_valid => true, :assumed_value => true)
    c_primitive_object = OpenEHR::AM::Archetype::ConstraintModel::CPrimitiveObject.new(
      :path => 'event/test', :rm_type_name => 'DV_BOOLEAN',
      :node_id => 'ac0001',
      :occurrences => OpenEHR::AssumedLibraryTypes::Interval.new(:lower => 0, :upper => 1),
      :item => item)
    expect(c_primitive_object.assumed_value).to eq(true)
    expect(c_primitive_object.has_assumed_value?).to be true
  end

  it 'any_allowed? should still be true when item is nil, unaffected by the delegated method list' do
    @c_primitive_object.item = nil
    expect(@c_primitive_object.any_allowed?).to be true
  end
end
