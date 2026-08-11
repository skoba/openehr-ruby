require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe 'ADL specialise header' do
  context 'a specialised archetype' do
    let(:archetype) { adl14_archetype('openEHR-EHR-CLUSTER.exam-abdomen.v1.adl') }

    it 'retains the parent archetype id from the specialise header' do
      expect(archetype.parent_archetype_id.value).to eq('openEHR-EHR-CLUSTER.exam.v1')
    end
  end

  context 'an archetype with no specialise header' do
    let(:archetype) { adl14_archetype('openEHR-EHR-CLUSTER.anatomical_location.v1.adl') }

    it 'has no parent archetype id' do
      expect(archetype.parent_archetype_id).to be_nil
    end
  end
end
