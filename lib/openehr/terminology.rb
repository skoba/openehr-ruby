$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
module OpenEHR
  module Terminology
    autoload :OpenEHRTerminology, 'terminology/open_ehr_terminology'
  end
end
