$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'common/archetyped'
require 'common/generic'
require 'common/change_control'
require 'common/directory'
require 'common/resource'

module OpenEHR
  module RM
    module Common
      include Archetyped
      include Generic
      include ChangeControl
      include Directory
      include Resource
    end
  end
end
