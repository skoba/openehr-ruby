source "http://rubygems.org"

gemspec
require 'rbconfig'
if RbConfig::CONFIG['target_os'] =~ /(?i-mx:bsd|dragonfly)/
  gem 'rb-kqueue', '>= 0.2'
end

group :development, :test do
  gem 'rspec'
  gem 'rspec-expectations'
  gem 'rspec-collection_matchers'
  gem 'guard'
  gem 'guard-rspec'
  gem 'simplecov'
  gem 'libnotify'
  gem 'rubocop'
  gem 'meowcop'
  gem 'better_errors'
end
