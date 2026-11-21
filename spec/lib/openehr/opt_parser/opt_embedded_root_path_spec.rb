require File.dirname(__FILE__) + '/../../../spec_helper'

# Issue #43, resolution shape (a) bug: an embedded C_ARCHETYPE_ROOT's own
# path got no bracket at all, so it equalled its parent attribute's path
# and every descendant inherited the gap. The bracket holds the embedded
# root's archetype id (ruling R-20261120-1 D1, issue #43's rewritten
# acceptance criteria), not its node_id. Fixture: eReferral.opt, a real
# OPT already in this suite (40 embedded roots). Written red-first
# against master f9509c7.
describe 'OPTParser#parse embedded C_ARCHETYPE_ROOT paths (#43)' do
  let(:opt) { OpenEHR::Parser::OPTParser.new(File.dirname(__FILE__) + '/eReferral.opt').parse }
  let(:root_class) { OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot }

  def each_node(node, &block)
    yield node
    return unless node.respond_to?(:attributes)

    (node.attributes || []).each do |attribute|
      (attribute.children || []).each { |child| each_node(child, &block) }
    end
  end

  def embedded_roots
    roots = []
    each_node(opt.definition) { |node| roots << node if node.is_a?(root_class) && !node.equal?(opt.definition) }
    roots
  end

  it "ends every embedded root's path with its own [archetype_id] bracket (all 40)" do
    expect(embedded_roots.size).to eq 40
    without_bracket = embedded_roots.reject { |root| root.path.end_with?("[#{root.archetype_id.value}]") }
    expect(without_bracket.map(&:path)).to eq []
  end

  it 'writes the bracket after the parent attribute, e.g. /context/other_context[at0001]/items[archetype_id]' do
    personal = embedded_roots.find { |root| root.archetype_id.value == 'openEHR-EHR-CLUSTER.individual_personal.v1' }
    expect(personal.path).to eq '/context/other_context[at0001]/items[openEHR-EHR-CLUSTER.individual_personal.v1]'
  end

  it "builds every descendant's path on top of the embedded root's bracket" do
    embedded_roots.each do |root|
      each_node(root) do |node|
        next if node.equal?(root) || !node.respond_to?(:path)

        expect(node.path).to start_with(root.path).and include("[#{root.archetype_id.value}]")
      end
    end
  end

  # regression pin: already true on master before the fix - the top-level
  # definition is a CArchetypeRoot too, and its path stays "/". Red is not
  # achievable for this example.
  it 'keeps the top-level definition path at "/" (regression pin)' do
    expect(opt.definition.path).to eq '/'
  end

  # regression pin: already true on master before the fix (a bracket-less
  # segment is a legal path too). Red is not achievable for this example.
  it 'keeps every physical path syntactically valid (regression pin)' do
    expect(opt.physical_paths.reject { |path| OpenEHR::Path.valid?(path) }).to eq []
  end
end
