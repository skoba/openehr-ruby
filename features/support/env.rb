require 'spork'

Spork.prefork do
  $LOAD_PATH << File.expand_path('../../../lib', __FILE__)
  require 'openehr'
end

Spork.each_run do

end
