require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel::Primitive

describe CReal do
  before(:each) do
    @c_real = CReal.new(:default_value => 1.5,
                        :assumed_value => 2.3,
                        :type => 'Real',
                        :list => [-1.5,20.3])
  end

  it 'should be an instance of CReal' do
    expect(@c_real).to be_an_instance_of CReal
  end

  it 'type is DvReal' do
    expect(@c_real.type).to eq('Real')
  end

  describe '#valid_value?' do
    it 'is true for a Float in the list' do
      expect(@c_real.valid_value?(-1.5)).to be true
    end

    it 'is false for a value not in the list' do
      expect(@c_real.valid_value?(3.14)).to be false
    end

    it 'is false for a non-Numeric' do
      expect(@c_real.valid_value?('1.5')).to be false
    end

    it 'is true for an Integer value too (Numeric, not just Float)' do
      c_real = CReal.new(:list => [1.0, 2.0])
      expect(c_real.valid_value?(1)).to be true
    end
  end
end
