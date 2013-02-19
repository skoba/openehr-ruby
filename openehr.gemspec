lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "openehr/version"

Gem::Specification.new do |gem|
  gem.name = "openehr"
  gem.version = OpenEHR::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.authors = ["Shinji KOBAYASHI", "Akimichi Tatsukawa"]
  gem.email = "skoba@moss.gr.jp"

  gem.summary = "Ruby implementation of the openEHR specification"
  gem.description = "This project is an implementation of the openEHR specification on Ruby."
  gem.homepage = "http://openehr.jp"
  gem.license = "Apache 2.0"
  gem.extra_rdoc_files = [
    "README.rdoc"
  ]
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.add_dependency('xml-simple')
  gem.add_dependency('activesupport')
  gem.add_dependency('locale')
  gem.add_dependency('builder')
# gem 'jeweler'
  gem.add_dependency('i18n')
  gem.add_dependency('treetop')
  gem.add_dependency('polyglot')
  gem.add_dependency('rdoc')
  gem.add_dependency('sqlite3')
  gem.add_dependency('activerecord')

  gem.add_development_dependency('rspec')
  gem.add_development_dependency('cucumber')
  gem.add_development_dependency('guard')
  gem.add_development_dependency('guard-rspec', '~>2.4.0')
  gem.add_development_dependency('guard-cucumber')
#  gem.add_development_dependency('ruby-debug19')
  gem.add_development_dependency('spork', '> 1.0rc')
  gem.add_development_dependency('guard-spork')
  gem.add_development_dependency('simplecov')
  gem.add_development_dependency('listen', '0.6')
  gem.add_development_dependency('libnotify')
end

