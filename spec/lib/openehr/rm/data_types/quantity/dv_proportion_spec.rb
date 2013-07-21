require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity
include OpenEHR::RM::DataTypes::Quantity::ProportionKind

describe DvProportion do
  before(:all) do
    @dv_proportion0 = DvProportion.new(:numerator => 2,
                                       :denominator => 3,
                                       :type => PK_RATIO,
                                       :accuracy => 1,
                                       :accuracy_percent => true)
    @dv_proportion1 = DvProportion.new(:numerator => 3,
                                       :denominator => 1,
                                       :type => PK_UNITARY)
    @dv_proportion2 = DvProportion.new(:numerator => 5,
                                       :denominator => 100,
                                       :type => PK_PERCENT)
    @dv_proportion3 = DvProportion.new(:numerator => 7,
                                       :denominator => 8,
                                       :type => PK_FRACTION)
    @dv_proportion4 = DvProportion.new(:numerator => 9,
                                       :denominator => 10,
                                       :type => PK_INTEGER_FRACTION)
  end

  describe 'PK_RATIO type' do
    it 'should be an instance of DvProportion' do
      @dv_proportion0.should be_an_instance_of DvProportion
    end

    it 's numerator should be equal 2' do
      @dv_proportion0.numerator.should be_equal 2
    end

    it 's denominator should be equal 3' do
      @dv_proportion0.denominator.should be_equal 3
    end

    it 's type should be equal 0' do
      @dv_proportion0.type.should == 0
    end

    it 's magnitude should be 2/3' do
      @dv_proportion0.magnitude.should == 2.0/3.0
    end

    it 's accuracy should be 1' do
      @dv_proportion0.accuracy.should == 1
    end

    it 'is_integral? should be true' do
      @dv_proportion0.is_integral?.should be_true
    end

    it 'should be comperable to same type DvProportion' do
      dv_propotion_type = DvProportion.new(:numerator => 3,
                                           :denominator => 4,
                                           :type => 0)
      @dv_proportion0.is_strictly_comparable_to?(dv_propotion_type).
        should be_true
    end

    it 'should not be comparable to other type DvPropotion' do
      @dv_proportion0.is_strictly_comparable_to?(@dv_proportion1).
        should_not be_true
    end

    it 'should not be comperable to other class' do
      @dv_proportion0.is_strictly_comparable_to?(1).
        should_not be_true
    end

    it 'should raise ArguentError with invalid type -1' do
      expect {
        @dv_proportion0.type = -1
      }.to raise_error ArgumentError
    end

    it 'should raise ArgumentError with invalid type 5' do
      expect {
        @dv_proportion0.type = 5
      }.to raise_error ArgumentError
    end

    it 's precision should be 0' do
      @dv_proportion0.precision = 0
      @dv_proportion0.precision.should == 0
    end

    it 'should raise ArgumentError when is_integral? and precision !=0' do
      expect {@dv_proportion0.precision = 1}.to raise_error ArgumentError
    end

    it 'shoud not raise ArgumentError when is_not ntegral' do
      @dv_proportion0.numerator = 2.5
      expect {
        @dv_proportion0.precision = 1
      }.not_to raise_error
    end
  end

  describe 'PK_UNITARY type' do
    it 'should be an instance of DvPropotion' do
      @dv_proportion1.should be_an_instance_of DvProportion
    end

    it 'should raise ArgumentError without denominator 1' do
      expect {
        @dv_proportion1.denominator = 10
      }.to raise_error ArgumentError
    end
  end

  describe 'PK_PERCENT type' do
    it 'should be an instance of DvProportion' do
      @dv_proportion2.should be_an_instance_of DvProportion
    end

    it 'should raise ArgumentError without denominator 100' do
      expect {
        @dv_proportion2.denominator = 101
      }.to raise_error ArgumentError
    end
  end

  describe 'PK_FRACTION type' do
    it 'should be an instance of DvProportion' do
      @dv_proportion3.should be_an_instance_of DvProportion
    end

    it 'should raise ArgumentError with fractional denominator' do
      expect {
        @dv_proportion3.denominator = 0.5
      }.to raise_error ArgumentError
    end

    it 'should raise ArgumentError with fractional numerator' do
      expect {
        @dv_proportion3.numerator = 0.5
      }.to raise_error ArgumentError
    end
  end

  describe 'PK_FRACTION_INTEGER type' do
    it 'should be an instance of DvProportion' do
      @dv_proportion4.should be_an_instance_of DvProportion
    end

    it 'should raise ArgumentError with fractional denominator' do
      expect {
        @dv_proportion4.denominator = 0.5
      }.to raise_error ArgumentError

    end

    it 'should raise ArgumentError with fractional numerator' do
      expect {
        @dv_proportion4.numerator = 0.5
      }.to raise_error ArgumentError
    end
  end
end
