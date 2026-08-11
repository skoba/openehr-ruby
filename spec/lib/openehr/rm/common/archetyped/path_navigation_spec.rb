require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Archetyped

# Hand-built Pathable tree used to test path navigation independent of
# any concrete RM class:
#
#   root (PathNavTestNode, no archetype_node_id)
#     data: [child(at0001, name 'first'), child(at0001, name 'second'), child(at0002)]
#       each child has:
#         leaf: PathNavTestLeaf (a non-Pathable value, at0001's children only)
class PathNavTestLeaf
  attr_reader :archetype_node_id, :value

  def initialize(value)
    @value = value
  end
end

class PathNavTestNode < Pathable
  attr_accessor :archetype_node_id, :name, :data, :leaf
  path_attribute :data, :leaf

  def initialize(archetype_node_id: nil, name: nil)
    super()
    @archetype_node_id = archetype_node_id
    @name = name
  end
end

describe Pathable do
  describe 'path navigation (item_at_path / items_at_path / path_exists? / path_unique? / path_of_item)' do
    let(:root) { PathNavTestNode.new }

    describe 'root path' do
      it 'item_at_path("/") returns self' do
        expect(root.item_at_path('/')).to equal(root)
      end

      it 'items_at_path("/") returns [self]' do
        expect(root.items_at_path('/')).to eq([root])
      end

      it 'path_exists?("/") is true' do
        expect(root.path_exists?('/')).to be true
      end
    end

    describe 'single segment, no predicate, single-valued child' do
      before(:each) do
        root.leaf = PathNavTestNode.new(archetype_node_id: 'at0099')
      end

      it 'item_at_path returns the child' do
        expect(root.item_at_path('/leaf')).to equal(root.leaf)
      end

      it 'items_at_path wraps the single child in an Array' do
        expect(root.items_at_path('/leaf')).to eq([root.leaf])
      end
    end

    describe 'missing attribute or unmatched predicate' do
      it 'items_at_path returns [] for an attribute with no value' do
        expect(root.items_at_path('/leaf')).to eq([])
      end

      it 'item_at_path returns nil for an attribute with no value' do
        expect(root.item_at_path('/leaf')).to be_nil
      end

      it 'path_exists? is false' do
        expect(root.path_exists?('/leaf')).to be false
      end

      it 'items_at_path returns [] when a node_id predicate matches nothing' do
        root.data = [PathNavTestNode.new(archetype_node_id: 'at0001')]
        expect(root.items_at_path('/data[at0002]')).to eq([])
      end
    end

    describe 'node_id predicate filtering over an Array-valued attribute' do
      before(:each) do
        @first = PathNavTestNode.new(archetype_node_id: 'at0001')
        @second = PathNavTestNode.new(archetype_node_id: 'at0002')
        root.data = [@first, @second]
      end

      it 'selects only the matching sibling' do
        expect(root.item_at_path('/data[at0002]')).to equal(@second)
      end

      it 'items_at_path returns just the one match' do
        expect(root.items_at_path('/data[at0001]')).to eq([@first])
      end
    end

    describe 'nested segments (recursion into Pathable children)' do
      before(:each) do
        @inner_leaf = PathNavTestLeaf.new('systolic-value')
        @child = PathNavTestNode.new(archetype_node_id: 'at0001')
        @child.leaf = @inner_leaf
        root.data = [@child]
      end

      it 'resolves a path through a nested Pathable node' do
        expect(root.item_at_path('/data[at0001]/leaf')).to equal(@inner_leaf)
      end

      it 'resolves through to a non-Pathable terminal value' do
        expect(root.item_at_path('/data[at0001]/leaf').value).to eq('systolic-value')
      end

      it 'items_at_path returns [] when the path continues past a non-Pathable leaf' do
        expect(root.items_at_path('/data[at0001]/leaf/nonexistent')).to eq([])
      end
    end

    describe 'name-based disambiguation of siblings sharing a node_id' do
      before(:each) do
        @first = PathNavTestNode.new(archetype_node_id: 'at0001', name: double('name', value: 'first'))
        @second = PathNavTestNode.new(archetype_node_id: 'at0001', name: double('name', value: 'second'))
        root.data = [@first, @second]
      end

      it 'item_at_path raises PathNotUniqueError without a name predicate' do
        expect {
          root.item_at_path('/data[at0001]')
        }.to raise_error(OpenEHR::RM::Common::Archetyped::PathNotUniqueError)
      end

      it "items_at_path without a name predicate returns both siblings" do
        expect(root.items_at_path('/data[at0001]')).to contain_exactly(@first, @second)
      end

      it "a name predicate selects exactly one sibling" do
        expect(root.item_at_path("/data[at0001, 'second']")).to equal(@second)
      end

      it 'path_unique? is false without a name predicate, true with one' do
        expect(root.path_unique?('/data[at0001]')).to be false
        expect(root.path_unique?("/data[at0001, 'second']")).to be true
      end
    end

    describe '#path_of_item' do
      it 'returns "/" for self' do
        expect(root.path_of_item(root)).to eq('/')
      end

      it 'returns the canonical path of a direct child' do
        child = PathNavTestNode.new(archetype_node_id: 'at0099')
        root.leaf = child
        expect(root.path_of_item(child)).to eq('/leaf[at0099]')
      end

      it 'returns the canonical path of a nested child' do
        inner_leaf = PathNavTestLeaf.new('v')
        child = PathNavTestNode.new(archetype_node_id: 'at0001')
        child.leaf = inner_leaf
        root.data = [child]
        expect(root.path_of_item(inner_leaf)).to eq('/data[at0001]/leaf')
      end

      it 'omits the name predicate when the node_id is not ambiguous among siblings' do
        child = PathNavTestNode.new(archetype_node_id: 'at0001', name: double('name', value: 'only'))
        root.data = [child]
        expect(root.path_of_item(child)).to eq('/data[at0001]')
      end

      it 'includes the name predicate only when needed to disambiguate siblings' do
        first = PathNavTestNode.new(archetype_node_id: 'at0001', name: double('name', value: 'first'))
        second = PathNavTestNode.new(archetype_node_id: 'at0001', name: double('name', value: 'second'))
        root.data = [first, second]
        expect(root.path_of_item(first)).to eq("/data[at0001, 'first']")
        expect(root.path_of_item(second)).to eq("/data[at0001, 'second']")
      end

      it 'round-trips: item_at_path(path_of_item(x)) is x' do
        child = PathNavTestNode.new(archetype_node_id: 'at0099')
        root.leaf = child
        expect(root.item_at_path(root.path_of_item(child))).to equal(child)
      end

      it 'returns nil when the item is not reachable from self' do
        unrelated = PathNavTestNode.new(archetype_node_id: 'at0099')
        expect(root.path_of_item(unrelated)).to be_nil
      end
    end

    it 'accepts an OpenEHR::Path object as well as a String' do
      root.leaf = PathNavTestNode.new(archetype_node_id: 'at0099')
      path = OpenEHR::Path.parse('/leaf')
      expect(root.item_at_path(path)).to equal(root.leaf)
    end
  end
end
