$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module OpenEHR
  module AM
    autoload :Archetype, 'am/archetype'
    autoload :OpenEHRProfile, 'am/openehr_profile'

  end
end
