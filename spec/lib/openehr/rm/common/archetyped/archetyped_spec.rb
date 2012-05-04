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
    @archetyped.should be_an_instance_of Archetyped
  end

  it 'archetype id concept rm_name should be EHR' do
    @archetyped.archetype_id.rm_name.should == 'EHR'
  end

  it 'rm_version should 1.2.4' do
    @archetyped.rm_version.should == '1.2.4'
  end

  it 'template_id.value should be uk.nhs.cfh:openehr-EHR-COMPOSITION.admission_ed.v5' do
    @archetyped.template_id.value.should ==
      'uk.nhs.cfh:openehr-EHR-COMPOSITION.admission_ed.v5'
  end

  it 'should raise ArgumentError with nil rm_version' do
    lambda {
      @archetyped.rm_version = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty rm_version' do
    lambda {
      @archetyped.rm_version = ''
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil ArchetypeID' do
    lambda {
      @archetyped.archetype_id = nil
    }.should raise_error ArgumentError
  end
end
