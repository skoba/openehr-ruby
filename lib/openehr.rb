$:.unshift(File.dirname(__FILE__))
require 'openehr/version'
require 'easyload'

module OpenEHR
  include EasyLoad
end

