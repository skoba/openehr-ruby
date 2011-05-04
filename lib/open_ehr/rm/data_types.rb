$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
module OpenEHR
  module RM
    module DataTypes
      autoload :Basic, 'data_types/basic'
      autoload :Encapsulated, 'data_types/encapsulated'
      autoload :Quantity, 'data_types/quantity'
      autoload :Text, 'data_types/text'
      autoload :TimeSpecification, 'data_types/time_specification'
      autoload :URI, 'data_types/uri'
    end
  end
end
