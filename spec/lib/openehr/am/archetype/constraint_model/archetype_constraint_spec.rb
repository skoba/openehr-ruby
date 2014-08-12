describe OpenEHR::AM::Archetype::ConstraintModel::ArchetypeConstraint do
  before(:each) do
    parent = double(OpenEHR::AM::Archetype::ConstraintModel::ArchetypeConstraint, :path => '/data/[at0001]')
    @archetype_constraint =
      OpenEHR::AM::Archetype::ConstraintModel::ArchetypeConstraint.new(:path => '/data/events[at0003]/data/items[at0025]/value/magnitude',
                              :parent => parent)
  end

  it 'should be an instance of ArchetypeConstraint' do
    expect(@archetype_constraint).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::ArchetypeConstraint
  end

  it 'path should be assigned properly' do
    expect(@archetype_constraint.path).to eq('/data/events[at0003]/data/items[at0025]/value/magnitude')
  end

  it 'should raise ArgumentError when path is not assigned' do
    expect {
      @archetype_constraint.path = nil
    }.to raise_error ArgumentError
  end

  it 'has_path? should return true if it has path' do
    expect(@archetype_constraint).to have_path 'events[at0003]'
  end

  it 'has_path? should return false if ti does not have path' do
    expect(@archetype_constraint).not_to have_path 'events[at0004]'
  end

  it 'parent should assigned properly' do
    expect(@archetype_constraint.parent.path).to eq('/data/[at0001]')
  end

  it 'is congruent means this node starts from parent node' do
    expect(@archetype_constraint).not_to be_congruent
  end

  it 'is congruent when path starts with parent path' do
    @archetype_constraint.path = '/data/[at0001]/test'
    expect(@archetype_constraint).to be_congruent
  end

  it 'node_conforms_to return true if path is follower' do
    other = double(ArchetypeConstraint, :path => '/data/events[at0003]')
    expect(@archetype_constraint.node_conforms_to?(other)).to be_truthy
  end

  it 'node_conforms_to return false if path is other lineage' do
    other = double(ArchetypeConstraint, :path => '/event/')
    expect(@archetype_constraint.node_conforms_to?(other)).to be_falsey
  end
end
