require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Encapsulated
include OpenEHR::RM::DataTypes::Text

describe DvParsable do
  before(:each) do
    @dv_parsable = DvParsable.new(:value => 'test',
                                  :formalism => 'plain/text')
  end

  it 'should be an instance of DvParsable' do
    @dv_parsable.should be_an_instance_of DvParsable
  end

  it 'value should be test' do
    @dv_parsable.value.should == 'test'
  end

  it 's size should be 4' do
    @dv_parsable.size.should be_equal 4
  end

  it 's formalism should be plain/text' do
    @dv_parsable.formalism.should == 'plain/text'
  end

  it 'should raise ArgumentError formalism nil' do
    lambda {@dv_parsable.formalism = nil}.should raise_error(ArgumentError)
  end

  it 'should raise ArgumentError formalism empty' do
    lambda {@dv_parsable.formalism = ''}.should raise_error(ArgumentError)
  end
end
