$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require "openehr/version"

Gem::Specification.new do |gem|
  gem.name = "openehr"
  gem.version = OpenEHR::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.authors = ["Shinji KOBAYASHI", "Akimichi Tatsukawa", "Michael Deryugin", "Dmitry Lavrov", "Evgeny Strokov"]
  gem.email = "skoba@moss.gr.jp"

  gem.summary = "Ruby implementation of the openEHR specification"
  gem.description = "This project is an implementation of the openEHR specification on Ruby."
  gem.homepage = "http://openehr.jp"
  gem.license = "Apache 2.0"
  gem.metadata = { 'rubygems_mfa_required' => 'true' }
  gem.extra_rdoc_files = [
    "README.rdoc"
  ]
  gem.files         = `git ls-files -- lib/*`.split("\n")
  gem.files        += %w[README.rdoc]
  gem.require_path  = "lib"
  gem.required_ruby_version = '>= 3.2'

  gem.add_dependency('rake')
  gem.add_dependency('xml-simple')
  gem.add_dependency('activesupport')
  gem.add_dependency('locale')
  gem.add_dependency('builder')
  gem.add_dependency('i18n')
  gem.add_dependency('treetop')
  gem.add_dependency('rdoc')
  gem.add_dependency('nokogiri')
end

