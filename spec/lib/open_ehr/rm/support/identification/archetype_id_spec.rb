require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe ArchetypeID do
  before(:each) do
    @archetype_id = ArchetypeID.new(:value => 'openEHR-EHR-SECTION.physical_examination-prenatal.v2')
  end

  it 'should be an instance of ArchetypeID' do
    @archetype_id.should be_an_instance_of ArchetypeID
  end

  it 's value should be equal
       openEHR-EHR-SECTION.physical_examination-prenatal.v2' do
    @archetype_id.value.should ==
      'openEHR-EHR-SECTION.physical_examination-prenatal.v2'
  end
  it 's qualified_rm_entity should be openEHR-EHR-SECTION' do
    @archetype_id.qualified_rm_entity.should == 'openEHR-EHR-SECTION'
  end

  it 's rm_originator should be openEHR' do
    @archetype_id.rm_originator.should == 'openEHR'
  end

  it 's rm_name should be EHR' do
    @archetype_id.rm_name.should == 'EHR'
  end

  it 'rm_entity should be SECTION' do
    @archetype_id.rm_entity.should == 'SECTION'
  end

  it 's domain_concept should be physical_examination-prenatal' do
    @archetype_id.domain_concept.should == 'physical_examination-prenatal'
  end

  it 's concept name should be physical_examination' do
    @archetype_id.concept_name.should == 'physical_examination'
  end

  it 's specialisation should be prenatal' do
    @archetype_id.specialisation.should == 'prenatal'
  end

  it 's version_id should == v2' do
    @archetype_id.version_id.should == 'v2'
  end

  it 'should raise ArgumentError with wrong id format' do
    lambda {
      ArchetypeID.new(:value =>'wrong-format')
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil concept name' do
    lambda {
      @archetype_id.concept_name = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with wrong domain concept format' do
    lambda {
      @archetype_id.domain_concept = '0123'
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty rm_entity' do
    lambda {
      @archetype_id.rm_entity = ''
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil rm_entity' do
    lambda {
      @archetype_id.rm_entity = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty rm_originator' do
    lambda {
      @archetype_id.rm_originator = ''
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil rm_originator' do
    lambda {
      @archetype_id.rm_originator = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty specialisation' do
    lambda {
      @archetype_id.specialisation = ''
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError with nil specialisation' do
    lambda {
      @archetype_id.specialisation = nil
    }.should_not raise_error ArgumentError
  end

  describe 'another constructor' do
    before(:each) do
      @archetype_id = ArchetypeID.new(:rm_originator => 'openEHR',
                                      :rm_name => 'EHR',
                                      :rm_entity => 'EVALUATION',
                                      :concept_name => 'clinical_synopsis',
                                      :version_id => 'v1')
    end

    it 'should be an instance of ArchetypeID' do
      @archetype_id.should be_an_instance_of ArchetypeID
    end

    it 'domain_concept should be clinical_synopsis' do
      @archetype_id.domain_concept.should == 'clinical_synopsis'
    end
  end

  describe 'domain concept' do
    before(:each) do
      @archetype_id.domain_concept = 'progress_note-naturopathy'
    end

    it 'concept_name should be progress note' do
      @archetype_id.concept_name.should == 'progress_note'
    end

    it 'specialisation should be naturopathy' do
      @archetype_id.specialisation === 'naturopathy'
    end

    it 'should raise ArgumentError empty domain concept' do
      lambda {
        @archetype_id.domain_concept = ''
      }.should raise_error ArgumentError
    end

    it 'should raise ArgumentError nil domain concept' do
      lambda {
        @archetype_id.domain_concept = nil
      }.should raise_error ArgumentError
    end

    it 's specialisation may be empty' do
      @archetype_id.domain_concept = 'clinical_synopsis'
      @archetype_id.concept_name.should == 'clinical_synopsis'
    end
  end
end
