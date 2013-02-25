$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module OpenEHR
  module RM
    module Support
      autoload :AssumedTypes, 'support/assumed_types'
      autoload :Definition, 'support/definition'
      autoload :Identification, 'support/identification'
      autoload :Measurement, 'support/measurement'
    end
  end
end
