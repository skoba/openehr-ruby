require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Archetyped

describe Pathable do
  before(:each) do
    @pathable = Pathable.new
  end

  it 'should be an instance of Pathable' do
    expect(@pathable).to be_an_instance_of Pathable
  end

  describe 'path_attribute DSL' do
    before do
      stub_const('PathableTestBase', Class.new(Pathable) do
        attr_accessor :data, :state
        path_attribute :data, :state
      end)
      stub_const('PathableTestChild', Class.new(PathableTestBase) do
        attr_accessor :items
        path_attribute :items
      end)
    end

    it 'a class with no path_attribute declarations has none' do
      expect(Pathable.path_attributes).to eq([])
    end

    it 'a class collects its own path_attribute declarations' do
      expect(PathableTestBase.path_attributes).to contain_exactly(:data, :state)
    end

    it 'a subclass inherits its ancestors declarations plus its own' do
      expect(PathableTestChild.path_attributes).to contain_exactly(:data, :state, :items)
    end

    describe '#path_children' do
      it 'maps each declared attribute name to its current value' do
        node = PathableTestBase.new
        node.data = 'the-data'
        node.state = 'the-state'
        expect(node.path_children).to eq('data' => 'the-data', 'state' => 'the-state')
      end

      it 'omits attributes whose value is nil' do
        node = PathableTestBase.new
        node.data = 'the-data'
        expect(node.path_children).to eq('data' => 'the-data')
      end

      it 'includes inherited declarations too' do
        node = PathableTestChild.new
        node.data = 'd'
        node.items = %w[a b]
        expect(node.path_children).to eq('data' => 'd', 'items' => %w[a b])
      end
    end
  end
end
