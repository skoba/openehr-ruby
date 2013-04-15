$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'support/definition'
require 'support/identification'
require 'support/measurement'
#      require 'support/assumed_types'

module OpenEHR
  module RM
    module Support
      include Definition
      include Identification
      include Measurement
    end
  end
end
