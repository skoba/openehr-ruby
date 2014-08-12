require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser

describe Base do
  context 'create an instance' do
    before do
      adl_dir = File.dirname(__FILE__)+'/adl/'
      @bp = Base.new(adl_dir + 'openEHR-EHR-SECTION.summary.v1.adl')
    end

    it 'creates an instance' do
      expect(@bp).to be_an_instance_of Base
    end

    it 'returns filename' do
      expect(@bp.filename).to match /openEHR-EHR-SECTION.summary.v1.adl$/
    end
  end
end
