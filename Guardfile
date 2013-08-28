guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
  watch(%r{^lib/open_ehr/parser/.+\.tt}) { "spec/lib/open_ehr/parser" }
end

<<<<<<< HEAD
guard 'cucumber' do
=======
guard 'cucumber', :cli => '--drb --format progress --no-profile' do
>>>>>>> 2d53835918b918f081e4939d78f60386e6be6785
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end

guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch(%r{features/support/}) { :cucumber }
end

notification :libnotify, :timeout => 5, :transient => true, :append => false

