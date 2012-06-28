require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

shared_examples 'empty use archetypes' do
  describe 'empty use is assigned nil to be valid archtype' do
    it 'is not nil' do
      subject.should_not be_nil
    end
  end

  describe 'description for use is nil' do
    it 'use is nil' do
      subject.description.details['en'].use.should be_nil
    end
  end
end

describe 'Archetypes, which has empty use' do
  adls = ['openEHR-EHR-OBSERVATION.operation_record.v1.adl',
         'openEHR-EHR-CLUSTER.exam-abdomen.v1.adl',
         'openEHR-EHR-OBSERVATION.uterine_contractions.v1.adl',
         'openEHR-EHR-CLUSTER.exam-uterine_cervix.v1.adl',
         'openEHR-EHR-CLUSTER.exam-uterus.v1.adl']

  adls.each do |adl|
    subject { adl14_archetype(adl) }
    it_should_behave_like 'empty use archetypes'
    
  end
end
