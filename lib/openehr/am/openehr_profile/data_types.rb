$:.unshift(File.dirname(__FILE__)) 

module OpenEHR
  module AM
    module OpenEHRProfile
      module DataTypes
        require 'data_types/text'
        require 'data_types/quantity'
        require 'data_types/basic'
      end
    end
  end
end
