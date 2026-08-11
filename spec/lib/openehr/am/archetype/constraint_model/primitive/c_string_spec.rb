require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::RM::DataTypes::Text

describe CString do
  before(:each) do
    @default_value = DvText.new(:value => 'default')
    @c_string = CString.new(:default_value => @default_value,
                            :assumed_value => 'assumed',
                            :pattern => 't[a-z]st')
  end

  it 'should be an instance of CString' do
    expect(@c_string).to be_an_instance_of CString
  end

  it 'type is always String' do
    expect(@c_string.type).to eq('String')
  end

  it 'default should be assigned properly' do
    expect(@c_string.default_value.value).to eq('default')
  end

  it 'assumed_value should be assigned properly' do
    expect(@c_string.assumed_value).to eq('assumed')
  end

  it 'pattern should be assigned properly by constructor' do
    expect(@c_string.pattern).to eq('t[a-z]st')
  end

  it 'pattern should be assigned properly by method' do
    @c_string.pattern = '.*'
    expect(@c_string.pattern).to eq('.*')
  end

  it 'should raise ArgumentError if either list or pattern is not nil' do
    expect {
      @c_string.list = ['test','driven']
    }.to raise_error ArgumentError
  end

  it 'should allow both list and pattern to be nil (unconstrained/any_allowed)' do
    expect {
      @c_string.pattern = nil
    }.not_to raise_error
    expect(@c_string.pattern).to be_nil
    expect(@c_string.list).to be_nil
  end

  it 'defaults list_open to nil (unset)' do
    expect(@c_string.list_open).to be_nil
  end

  it 'accepts list_open as a constructor argument' do
    c_string = CString.new(:list => ['a'], :list_open => true)
    expect(c_string.list_open).to be true
  end

  describe '#valid_value?' do
    it 'matches the pattern' do
      expect(@c_string.valid_value?('test')).to be true
    end

    it 'does not match the pattern' do
      expect(@c_string.valid_value?('xyz')).to be false
    end

    it 'is false for a non-String' do
      expect(@c_string.valid_value?(123)).to be false
    end

    it 'is true for any String when unconstrained' do
      c_string = CString.new
      expect(c_string.valid_value?('anything')).to be true
    end

    context 'with a list constraint' do
      before(:each) do
        @c_string = CString.new(:list => ['test', 'behavior'])
      end

      it 'is true for a value in the list' do
        expect(@c_string.valid_value?('test')).to be true
      end

      it 'is false for a value not in the list' do
        expect(@c_string.valid_value?('other')).to be false
      end
    end
  end

  describe 'list attribute' do
    before(:each) do
      @default_value = DvText.new(:value => 'default')
      @c_string = CString.new(:default_value => @default_value,
                              :assumed_value => 'assumed',
                              :list => ['test', 'behavior'])
    end

    it 'list should be assigned properly by constructor' do
      expect(@c_string.list).to eq(['test', 'behavior'])
    end

    it 'list shoudl be assigned properly by method' do
      @c_string.list = ['spec']
      expect(@c_string.list).to eq(['spec'])
    end

    it 'should raise ArgumentError if both pattern and list is not nil' do
      expect {
        @c_string.pattern = 'file.*'
      }.to raise_error ArgumentError
    end
  end
end
