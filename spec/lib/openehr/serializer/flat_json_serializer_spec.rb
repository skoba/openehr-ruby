describe 'FlatJsonSerializer' do
  let(:optparser) { OpenEHR::Parser::OPTParser.new(File.join(File.dirname(__FILE__), '/minimum_template.opt'))}
  let(:opt) {optparser.parse}

end
