$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module OpenEHR
  module RM
    module Common
      autoload :Archetyped, 'common/archetyped'
      autoload :ChangeControl, 'common/change_control'
      autoload :Directory, 'common/directory'
      autoload :Generic, 'common/generic.rb'
      autoload :Resource, 'common/resource'
    end
  end
end
