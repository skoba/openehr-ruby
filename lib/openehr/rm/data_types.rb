$:.unshift(File.dirname(__FILE__))
require 'data_types/basic'
require 'data_types/encapsulated'
require 'data_types/quantity'
require 'data_types/quantity/date_time'
require 'data_types/text'
require 'data_types/time_specification'
require 'data_types/uri'

module OpenEHR
  module RM
    module DataTypes
      include Basic
      include Encapsulated
      include Quantity
      include Quantity::DateTime
      include Text
      include TimeSpecification
      include URI
    end
  end
end
