# rm::composition::content::navigation
# navigation module
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109264528523_312165_346Report.html
# refs #56
require_relative '../content'

module OpenEHR
  module RM
    module Composition
      module Content
        module Navigation
          class Section < ::OpenEHR::RM::Composition::Content::ContentItem
            attr_reader :items 

            def initialize(args = { })
              super(args)
              self.items = args[:items]
            end

            def items=(items)
              if !items.nil? && items.empty?
                raise ArgumentError, 'items should not be empty'
              end
              @items = items
            end
          end
        end
      end # end of Content
    end # end of Composition
  end # end of RM
end # end of OpenEHR
