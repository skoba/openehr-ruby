describe 'minimum_template' do
  let(:optparser) { OpenEHR::Parser::OPTParser.new(File.join(File.dirname(__FILE__), '/minimum_template.opt'))}
  let(:opt) {optparser.parse}

  it 'concept is minimum template' do
    expect(opt.concept).to eq 'minimum template'
  end

  it 'template_id is minimum template' do
    expect(opt.template_id).to eq 'minimum template'
  end
end
