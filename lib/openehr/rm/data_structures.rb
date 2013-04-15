# rm::data_structures
# class DATA_STRUCTURE
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_5_1_76d0249_1140447518205_872539_864Report.html
# refs #59

module OpenEHR
  module RM
    module DataStructures
      class DataStructure < ::OpenEHR::RM::Common::Archetyped::Locatable
        def initialize(args = { })
          super(args)
        end

        def as_hierarchy
          raise NotImplementedError, "as_hirarchy must be implemented"
        end
      end

      require 'openehr/rm/data_structures/item_structure'
      include OpenEHR::RM::DataStructures::ItemStructure

      require 'openehr/rm/data_structures/history'
      include History
    end # of Data_Structures
  end # of RM
end # of OpenEHR
