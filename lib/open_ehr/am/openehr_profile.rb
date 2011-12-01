$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module OpenEHR
  module AM
    module OpenEHRProfile
      autoload :DataTypes, 'openehr_profile/data_types'
    end
  end
end
