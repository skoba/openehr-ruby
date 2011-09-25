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
    @c_real.should be_an_instance_of CReal
  end

  it 'type is DvReal' do
    @c_real.type.should == 'Real'
  end
end
