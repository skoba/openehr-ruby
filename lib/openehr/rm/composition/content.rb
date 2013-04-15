$:.unshift(File.dirname(__FILE__))
# rm::composition::content
# content module
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_5_1_76d0249_1140524925046_706492_3290Report.html
# refs #58

module OpenEHR
  module RM
    module Composition
      module Content
        class ContentItem < OpenEHR::RM::Common::Archetyped::Locatable

        end

        require 'content/navigation'
        require 'content/entry'

        include Navigation
        include Entry
      end # end of Content
    end # end of Composition
  end # end of RM
end # end of OpenEHR
