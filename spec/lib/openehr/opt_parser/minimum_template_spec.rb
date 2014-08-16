describe 'minimum_template' do
  let(:optparser) { OpenEHR::Parser::OPTParser.new(File.join(File.dirname(__FILE__), '/minimum_template.opt'))}
  let(:opt) {optparser.parse}

  it 'concept is minimum template' do
    expect(opt.concept).to eq 'minimum template'
  end

  it 'template_id is minimum template' do
    expect(opt.template_id.value).to eq 'minimum template'
  end

  it 'template uid is assigned' do
    expect(opt.uid.value).to eq '199f6890-5c06-4cb2-92de-422848ffe3a8'
  end
end
