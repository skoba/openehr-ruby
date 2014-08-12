require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe TemplateID do
  before(:each) do
    @template_id = TemplateID.new(:value => 'uk.nhs.cfh:openehr-EHR-COMPOSITION.admission_ed.v5')
  end

  it 'should be an isntance of TemplateID' do
    expect(@template_id).to be_an_instance_of TemplateID
  end
end
