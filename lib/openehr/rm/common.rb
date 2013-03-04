$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module OpenEHR
  module RM
    module Common
      require 'common/archetyped'
      require 'common/generic'
      require 'common/change_control'
      require 'common/directory'
      require 'common/resource'
    end
  end
end
