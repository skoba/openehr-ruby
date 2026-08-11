describe CBoolean do
  before(:each) do
    default_value = true
    @c_boolean = OpenEHR::AM::Archetype::ConstraintModel::Primitive::CBoolean.new(:default_value => default_value,
                              :type => 'Boolean',
                              :true_valid => true,
                              :false_valid => true)
  end

  it 'should be_an_instance_of CBoolean' do
    expect(@c_boolean).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::Primitive::CBoolean
  end

  it 'true_valid should be assigned properly' do
    expect(@c_boolean).to be_true_valid
  end

  it 'false_valid should be assigned properly' do
    expect(@c_boolean).to be_false_valid
  end

  it 'type should be DvBoolean' do
    expect(@c_boolean.type).to eq('Boolean')
  end

  it 'should raise ArgumentError when both true_valid and false_valid are false' do
    expect {
      @c_boolean.true_valid = false
      @c_boolean.false_valid = false
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError if both false_valid and true_valid  are false' do
    expect {
      @c_boolean.false_valid = false
      @c_boolean.true_valid = false
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError if default_value is false and false_valid is false' do
    expect {
      @c_boolean.false_valid = false
      @c_boolean.default_value = false
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError if default_value is true and true_valid is false' do
    expect {
      @c_boolean.true_valid = false
      @c_boolean.default_value = true
    }.to raise_error ArgumentError
  end

  describe '#valid_value?' do
    it 'is true for true when true_valid' do
      expect(@c_boolean.valid_value?(true)).to be true
    end

    it 'is true for false when false_valid' do
      expect(@c_boolean.valid_value?(false)).to be true
    end

    it 'is false for true when only false_valid' do
      c_boolean = OpenEHR::AM::Archetype::ConstraintModel::Primitive::CBoolean.new(:true_valid => false, :false_valid => true)
      expect(c_boolean.valid_value?(true)).to be false
    end

    it 'is false for a non-boolean value' do
      expect(@c_boolean.valid_value?('true')).to be false
    end
  end
end
