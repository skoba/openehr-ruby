require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Archetyped
include OpenEHR::RM::Support::Identification

describe Archetyped do
  before(:each) do
    archetype_id = ArchetypeID.new(:value => 
                      'openEHR-EHR-SECTION.physical_examination.v2')
    template_id = TemplateID.new(:value =>
                   'uk.nhs.cfh:openehr-EHR-COMPOSITION.admission_ed.v5')
    @archetyped = Archetyped.new(:archetype_id => archetype_id,
                                 :rm_version => '1.2.4',
                                 :template_id => template_id)
  end

  it 'should be an instance of Archetyped' do
    expect(@archetyped).to be_an_instance_of Archetyped
  end

  it 'archetype id concept rm_name should be EHR' do
    expect(@archetyped.archetype_id.rm_name).to eq('EHR')
  end

  it 'rm_version should 1.2.4' do
    expect(@archetyped.rm_version).to eq('1.2.4')
  end

  it 'template_id.value should be uk.nhs.cfh:openehr-EHR-COMPOSITION.admission_ed.v5' do
    expect(@archetyped.template_id.value).to eq(
      'uk.nhs.cfh:openehr-EHR-COMPOSITION.admission_ed.v5'
    )
  end

  it 'should raise ArgumentError with nil rm_version' do
    expect {
      @archetyped.rm_version = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty rm_version' do
    expect {
      @archetyped.rm_version = ''
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil ArchetypeID' do
    expect {
      @archetyped.archetype_id = nil
    }.to raise_error ArgumentError
  end
end
