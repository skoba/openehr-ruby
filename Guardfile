guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
  watch(%r{^lib/open_ehr/parser/.+\.tt}) { "spec/lib/open_ehr/parser" }
end

guard 'spork', :wait => 30, :cucumber => false do
  watch('spec/spec_helper.rb')
end
