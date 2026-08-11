require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Composition
include OpenEHR::RM::Composition::Content::Navigation
include OpenEHR::RM::Composition::Content::Entry
include OpenEHR::RM::DataStructures::History
include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::DataStructures::ItemStructure::Representation
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity
include OpenEHR::RM::DataTypes::Quantity::DateTime

# End-to-end path navigation over a real (non-doubled) RM object graph:
#   Composition -> Section -> Observation -> History -> PointEvent
#     -> ItemTree -> Element -> DvQuantity
describe 'path navigation over a real Composition tree' do
  before(:each) do
    @systolic = Element.new(:archetype_node_id => 'at0004',
                            :name => DvText.new(:value => 'Systolic'),
                            :value => DvQuantity.new(:magnitude => 120, :units => 'mm[Hg]'))
    diastolic = Element.new(:archetype_node_id => 'at0005',
                            :name => DvText.new(:value => 'Diastolic'),
                            :value => DvQuantity.new(:magnitude => 80, :units => 'mm[Hg]'))
    item_tree = ItemTree.new(:archetype_node_id => 'at0003',
                             :name => DvText.new(:value => 'Data'),
                             :items => [@systolic, diastolic])
    point_event = PointEvent.new(:archetype_node_id => 'at0006',
                                 :name => DvText.new(:value => 'Any event'),
                                 :time => DvDateTime.new(:value => '2020-01-01T10:00:00'),
                                 :data => item_tree)
    history = OpenEHR::RM::DataStructures::History::History.new(
                          :archetype_node_id => 'at0002',
                          :name => DvText.new(:value => 'History'),
                          :origin => DvDateTime.new(:value => '2020-01-01T10:00:00'),
                          :events => [point_event])
    @observation = Observation.new(:archetype_node_id => 'at0001',
                                   :name => DvText.new(:value => 'Blood pressure'),
                                   :language => double('language', :code_string => 'en'),
                                   :encoding => double('encoding', :code_string => 'UTF-8'),
                                   :subject => double('subject'),
                                   :data => history)
    section = Section.new(:archetype_node_id => 'at0007',
                          :name => DvText.new(:value => 'Vitals'),
                          :items => [@observation])
    @composition = Composition.new(:archetype_node_id => 'at0008',
                                   :name => DvText.new(:value => 'Encounter'),
                                   :language => double('language'),
                                   :category => double('category'),
                                   :territory => double('territory'),
                                   :composer => double('composer'),
                                   :content => [section])
  end

  it 'navigates from the composition root to a deeply nested element value' do
    path = '/content[at0007]/items[at0001]/data[at0002]/events[at0006]/data[at0003]/items[at0004]/value'
    expect(@composition.item_at_path(path)).to equal(@systolic.value)
  end

  it 'items_at_path returns a single-element array for the same path' do
    path = '/content[at0007]/items[at0001]/data[at0002]/events[at0006]/data[at0003]/items[at0004]/value'
    expect(@composition.items_at_path(path)).to eq([@systolic.value])
  end

  it 'path_exists? is true for a valid path and false for a bogus one' do
    expect(@composition.path_exists?('/content[at0007]')).to be true
    expect(@composition.path_exists?('/content[at9999]')).to be false
  end

  it 'item_at_path returns the Observation itself for an intermediate path' do
    expect(@composition.item_at_path('/content[at0007]/items[at0001]')).to equal(@observation)
  end

  it 'path_of_item produces a path that round-trips back to the same element' do
    path = @composition.path_of_item(@systolic)
    expect(@composition.item_at_path(path)).to equal(@systolic)
  end
end
