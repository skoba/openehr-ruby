$:.unshift(File.dirname(__FILE__))

module OpenEHR
  module RM
    module DataTypes
      require 'data_types/basic'
      require 'data_types/encapsulated'
      require 'data_types/quantity'
      require 'data_types/quantity/date_time'
      require 'data_types/text'
      require 'data_types/time_specification'
      require 'data_types/uri'
    end
  end
end
