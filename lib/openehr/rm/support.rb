$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module OpenEHR
  module RM
    module Support
#      require 'support/assumed_types'
      require 'support/definition'
      require 'support/identification'
      require 'support/measurement'
    end
  end
end
