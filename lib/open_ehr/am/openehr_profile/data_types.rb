$:.unshift(File.dirname(__FILE__)) 

module OpenEHR
  module AM
    module OpenEHRProfile
      module DataTypes
        autoload :Text, 'data_types/text'
        autoload :Quantity, 'data_types/quantity'
        autoload :Basic, 'data_types/basic'
      end
    end
  end
end
