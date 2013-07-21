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
  gem.extra_rdoc_files = [
    "README.rdoc"
  ]
  gem.files         = `git ls-files -- lib/*`.split("\n")
  gem.files        += %w[README.rdoc]
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_path  = "lib"

  gem.add_dependency('rake')
  gem.add_dependency('xml-simple')
  gem.add_dependency('activesupport')
  gem.add_dependency('locale')
  gem.add_dependency('builder')
  gem.add_dependency('i18n')
  gem.add_dependency('treetop','1.4.12')
  gem.add_dependency('polyglot')
  gem.add_dependency('rdoc')
#  gem.add_dependency('sqlite3')
#  gem.add_dependency('activerecord')

  gem.add_development_dependency('rspec')
  gem.add_development_dependency('cucumber')
  gem.add_development_dependency('guard')
  gem.add_development_dependency('guard-rspec')
  gem.add_development_dependency('guard-cucumber')
#  gem.add_development_dependency('ruby-debug19')
  gem.add_development_dependency('spork', '> 1.0rc')
  gem.add_development_dependency('guard-spork')
  gem.add_development_dependency('simplecov')
  gem.add_development_dependency('listen') #,'0.6.0')
  gem.add_development_dependency('rb-kqueue')
  gem.add_development_dependency('libnotify')
end

