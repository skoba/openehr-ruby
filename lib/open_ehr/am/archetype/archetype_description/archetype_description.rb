
module OpenEhr
  module AM
    module Archetype
      module Archetype_Description
        class ARCHETYPE_DESCRIPTION
          attr_accessor :archetype_package_uri, :lifecycle_state, :original_author, :other_contributors, :other_details, :details
          def initialize(args ={ })
            @details = args[:details] ? args[:details] : []
          end
        end

        class ARCHETYPE_DESCRIPTION_ITEM
          attr_accessor :archetype_package_uri, :lifecycle_state, :original_author, :other_contributors, :other_details
        end
      end
    end
  end
end


