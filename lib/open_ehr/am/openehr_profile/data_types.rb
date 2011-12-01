$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module OpenEHR
  module AM
    module OpenEHRProfile
      module DataTypes
        autoload :Text, 'data_types/text'
      end
    end
  end
end
