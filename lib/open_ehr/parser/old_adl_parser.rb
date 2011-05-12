# component: openEHR Ruby ADL parser implementation
# description: 
# keywords: archetype, ADL, parser
# author: Akimichi TATSUKAWA, Shinji KOBAYASHI
# support: openEHR.jp
# license: openEHR open source license

$:.unshift File.join(File.dirname(__FILE__))
require 'logger'
require 'adl_scanner.rb'
require 'adl_exception.rb'
require 'parser.rb'

module OpenEHR

  if $DEBUG
    LOG = Logger.new('log/adl_parser.log','daily')
    LOG.level = Logger::INFO
  else
    LOG = Logger.new(STDOUT)
    LOG.level = Logger::WARN
  end


  module ADL
    autoload :Parser, "parser.rb"
    autoload :Validator, "validator.rb"

    module Scanner
      module DADL
        autoload :RootScanner, "adl_scanner.rb"
      end
      module CADL
        autoload :RootScanner, "adl_scanner.rb"
      end
    end
  end

  module Application
    autoload :ADLValidator, "shell.rb"
  end # of Application

  
end # of OpenEHR
