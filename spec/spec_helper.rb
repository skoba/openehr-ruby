require 'rubygems'
require 'spork'
require 'simplecov'

$:.unshift(File.dirname(__FILE__) + '/../lib')

<<<<<<< HEAD
require 'openehr'
=======
Spork.prefork do
>>>>>>> 2d53835918b918f081e4939d78f60386e6be6785

Spork.prefork do
  SimpleCov.start
end

Spork.each_run do
<<<<<<< HEAD
=======

end

>>>>>>> 2d53835918b918f081e4939d78f60386e6be6785

end
