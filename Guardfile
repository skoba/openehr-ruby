guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
end

guard 'spork' do
  # watch('config/application.rb')
  # watch('config/environment.rb')
  # watch(%r{^config/environments/.+\.rb$})
  # watch(%r{^config/initializers/.+\.rb$})
  watch('spec/spec_helper.rb')
end
