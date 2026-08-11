require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'OpenEHR::Parser::Exception::Validation' do
  it 'defines the VARID..VDFPT archetype-validation error constants' do
    %w[VARID VARCN VARDF VARON VARDT VATDF VACDF VDFAI VDFPT].each do |name|
      expect(OpenEHR::Parser::Exception::Validation.const_defined?(name)).to be true
    end
  end

  it 'each error is a StandardError carrying a descriptive MESSAGE' do
    error = OpenEHR::Parser::Exception::Validation::VARID
    expect(error.ancestors).to include(StandardError)
    expect(error::MESSAGE).to be_a(String)
  end
end
