require 'rubygems'
require 'spork'
require 'simplecov'

SimpleCov.start

Spork.prefork do

end

Spork.each_run do

end


begin
  require 'rspec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'rspec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
#$:.unshift(File.dirname(__FILE__) + '/..')
require 'openehr'
