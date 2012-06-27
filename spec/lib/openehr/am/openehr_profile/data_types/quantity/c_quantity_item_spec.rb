# ticket 203
include OpenEHR::AssumedLibraryTypes
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity

describe CQuantityItem do
  before(:each) do
    magnitude = Interval.new(:upper => 100, :lower => 0)
    precision = Interval.new(:upper => 10, :lower => 2)
    @c_quantity_item = CQuantityItem.new(:units => 'mg',
                                         :magnitude => magnitude,
                                         :precision => precision)
  end

  it 'is an instance of CQuantityItem' do
    @c_quantity_item.should be_an_instance_of CQuantityItem
  end

  it 'magnitude upper is 100' do
    @c_quantity_item.magnitude.upper.should be 100
  end

  it 'precision lower is -2' do
    @c_quantity_item.precision.lower.should be 2
  end

  it 'units is not nil' do
    expect {@c_quantity_item.units = nil}.to raise_error
  end

  it 'units is not be empty' do
    expect {@c_quantity_item.units = ''}.to raise_error
  end

  it 'is not precision unconstrained' do
    @c_quantity_item.should_not be_precision_unconstrained
  end
  context 'precision unconstrained' do
    before(:each) do
      @c_quantity_item.precision = Interval.new(:upper => -1, :lower => -1)
    end

    it 'precision unconstrained is true' do
      @c_quantity_item.should be_precision_unconstrained
    end
  end
end
