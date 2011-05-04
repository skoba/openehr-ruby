require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
#require 'bundle'
require './lib/open_ehr'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

$hoe = Hoe.spec 'open_ehr' do
  self.developer 'Shinji KOBAYASHI', 'skoba@moss.gr.jp'
  self.post_install_message = 'PostInstall.txt'
  self.rubyforge_name       = self.name # TODO this is default value
  # self.extra_deps         = [['activesupport','>= 2.0.2']]

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:spec, :features]
