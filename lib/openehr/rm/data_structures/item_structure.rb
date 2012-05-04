# rm::data_structures::item_structure
# ItemStructure module
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109346709572_859750_3810Report.html
# refs #54
$:.unshift(File.dirname(__FILE__))

require 'set'
#include OpenEHR::RM::DataStructures
module OpenEHR
  module RM
    module DataStructures
      module ItemStructure

        autoload :Representation, 'item_structure/representation'

        class ItemStructure < DataStructure
        end

        class ItemSingle < ItemStructure
          attr_reader :item

          def initialize(args = {})
            super(args)
            self.item = args[:item]
          end

          def as_hierarchy
            return @item
          end

          def item=(item)
            raise ArgumentError, 'item is mandatory' if item.nil?
            @item = item
          end
        end

        class ItemList < ItemStructure
          attr_accessor :items

          def initialize(args = {})
            super(args)
            self.items = args[:items]
          end

          def item_count
            unless @items.nil?
              return @items.size
            else
              return 0
            end
          end

          def names
            return @items.collect{|item| item.name}
          end

          def named_item(a_name)
            @items.each do |item|
              return item if item.name.value == a_name
            end
            return nil
          end

          def ith_item(i)
            raise ArgumentError, 'index invalid' if i <= 0
            return @items[i - 1]
          end

          def as_hierarchy
            return Cluster.new(:name => @name,
                               :archetype_node_id => @archetype_node_id,
                               :items => @items)
          end
        end

        class ItemTable < ItemStructure
          attr_accessor :rows

          def initialize(args = {})
            super(args)
            self.rows = args[:rows]
          end

          def row_count
            if @rows.nil?
              return 0
            else
              return @rows.size
            end
          end

          def column_count
            if @rows.nil?
              return 0
            else
              return @rows[0].items.count
            end
          end

          def row_names
            if @rows.nil?
              return []
            else
              return @rows.collect{|r| r.name}
            end
          end

          def column_names
            if @rows.nil?
              return []
            else
              return @rows[0].items.collect{|i| i.name}
            end
          end

          def ith_row(i)
            raise ArgumentError, 'invalid index' if i<=0 or i>@rows.size
            return @rows[i - 1]
          end

          def has_row_with_name?(key)
            raise ArgumentError, 'invalid argument' if key.nil? or key.empty?
            @rows.each do |row|
              return true if row.items[0].name.value == key
            end
            return false
          end

          def has_column_with_name?(key)
            raise ArgumentError, 'invalid argument' if key.nil? or key.empty?
            self.column_names.each do |name|
              return true if name.value == key
            end
            return false
          end

          def named_row(key)
            raise ArgumentError, 'invalid argument' unless has_row_with_name?(key)
            @rows.each do |row|
              return row if row.items[0].name.value == key
            end
          end

          def has_row_with_key?(keys)
            keys.each do |key|
              @rows.each do |row|
                return true if row.items[0].name.value == key
              end
            end
            return false
          end

          def row_with_key(keys)
            unless has_row_with_key?(keys)
              raise ArgumentError, 'no row for key'
            end
            keys.each do |key|
              @rows.each do |row|
                return row if row.items[0].name.value == key
              end
            end
          end

          def element_at_cell_ij(i,j)
            return @rows[i-1].items[j-1]
          end

          def element_at_named_cell(row_key, column_key)
            i,j=0,0
            @rows[0].items.each do |c|
              break if c.name.value == column_key
              i+=1
            end
            @rows.each do |row|
              break if row.name.value == row_key
              j+=1
            end            
            return element_at_cell_ij(i,j)
          end

          def as_hierarchy
            return @rows[0]
          end
        end

        class ItemTree < ItemStructure
          attr_accessor :items

          def initialize(args ={ })
            super(args)
            self.items = args[:items]
          end

          def has_element_path?(path)
            paths = [ ]
            @items.each do |item|
              paths << item.archetype_node_id
            end
            return paths.include? path
          end

          def element_at_path(path)
            @items.each do |item|
              return item if item.archetype_node_id == path
            end
            return nil
          end

          def as_hierarchy
            return Cluster.new(:name => @name,
                               :archetype_node_id => @archetype_node_id,
                               :items => @items)
          end
        end
      end # of ItemStructure
    end # of DataStructures
  end # of RM
end # of OpenEHR
