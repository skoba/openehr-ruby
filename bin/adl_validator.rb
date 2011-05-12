#!/usr/bin/env ruby
require 'rubygems'
require "adl_parser"
require 'readline'
require 'optparse'
require 'net/http'

module OpenEhr
  module CommandLine
    class Arguments < Hash
      def initialize(args)
        super() # default values
        opts = ::OptionParser.new do |opts|
          opts.banner = "Usage: #$0 [file|http://location.to.adl]* [options]"
          opts.on('-v', '--verbose', 'display verbose message(Not Implemented Yet)') do
            self[:verbose] = true
          end
          opts.on_tail('-h', '--help', 'display this help') do
            puts opts
            exit
          end
        end
        opts.parse!(args)
      end
    end

    class ADLValidator
      def initialize(arguments)
        @debug = false
        @adl_validator = ::OpenEHR::Application::ADLValidator.new(::OpenEHR::ADL::Validator.new(::OpenEHR::ADL::Parser.new))
      end

      def run
        while argv = ARGV.shift
          begin
            input = nil
            name = nil
            case argv
            when /\A(http:\/\/.*)/
              name = $1
              input = case response = Net::HTTP.get_response(Uri.parse($1))
                      when Net::HTTPSuccess   
                        response.body
                      when Net::HTTPRedirection
                        name = response['location']
                        fetch(response['location'], limit - 1)
                      else
                        response.error!
                      end
            when /\A("[^"]*)"/
              name = argv
              input = argv
            else # assumes file name
              name = argv
              input = File.new(argv)
            end
            @adl_validator.run(input, name)
          rescue SocketError => message
            puts "SocketError: #{message}"
          rescue Racc::ParseError => message
            puts "ParseError: #{message}"
          else
            puts "Accepted '#{argv}'"
          ensure
#            input.close if input.kind_of? IO
          end
        end
      end
    end
  end # of CommandLine
end # of OpenEHR

if __FILE__ == $0
  begin
    arguments = OpenEhr::CommandLine::Arguments.new(ARGV)
    validator = OpenEhr::CommandLine::ADLValidator.new(arguments)
    validator.run
  end
end





