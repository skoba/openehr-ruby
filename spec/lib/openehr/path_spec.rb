require File.dirname(__FILE__) + '/../../spec_helper'

describe OpenEHR::Path do
  describe '.parse' do
    context 'root path' do
      it 'parses "/" as the root path' do
        path = OpenEHR::Path.parse('/')
        expect(path.root?).to be true
      end

      it 'has no segments' do
        expect(OpenEHR::Path.parse('/').segments).to eq([])
      end
    end

    context 'single segment, no predicate' do
      it 'parses the attribute name' do
        path = OpenEHR::Path.parse('/content')
        expect(path.segments.size).to eq(1)
        expect(path.segments[0].attribute).to eq('content')
      end

      it 'is not root' do
        expect(OpenEHR::Path.parse('/content').root?).to be false
      end

      it 'has no predicate' do
        segment = OpenEHR::Path.parse('/content').segments[0]
        expect(segment.predicate?).to be false
        expect(segment.archetype_node_id).to be_nil
        expect(segment.name).to be_nil
      end
    end

    context 'multiple segments' do
      it 'parses each attribute in order' do
        path = OpenEHR::Path.parse('/content/data/value')
        expect(path.segments.map(&:attribute)).to eq(%w[content data value])
      end
    end

    describe '#to_s canonical form' do
      it 'round-trips a single-segment path' do
        expect(OpenEHR::Path.parse('/content').to_s).to eq('/content')
      end

      it 'round-trips a multi-segment path' do
        expect(OpenEHR::Path.parse('/content/data/value').to_s).to eq('/content/data/value')
      end

      it 'round-trips the root path' do
        expect(OpenEHR::Path.parse('/').to_s).to eq('/')
      end
    end

    describe 'equality and hashing' do
      it 'two paths parsed from the same string are ==' do
        expect(OpenEHR::Path.parse('/content/data')).to eq(OpenEHR::Path.parse('/content/data'))
      end

      it 'two paths parsed from different strings are not ==' do
        expect(OpenEHR::Path.parse('/content/data')).not_to eq(OpenEHR::Path.parse('/content/state'))
      end

      it 'equal paths have equal hashes (usable as Hash keys)' do
        h = { OpenEHR::Path.parse('/content/data') => :found }
        expect(h[OpenEHR::Path.parse('/content/data')]).to eq(:found)
      end
    end

    describe '#parent' do
      it 'drops the last segment' do
        expect(OpenEHR::Path.parse('/content/data').parent).to eq(OpenEHR::Path.parse('/content'))
      end

      it 'the root path is its own parent' do
        root = OpenEHR::Path.parse('/')
        expect(root.parent).to eq(root)
      end
    end

    describe '#+' do
      it 'appends a Segment' do
        base = OpenEHR::Path.parse('/content')
        segment = OpenEHR::Path.parse('/data').segments[0]
        expect((base + segment).to_s).to eq('/content/data')
      end

      it 'appends another Path (concatenates segments)' do
        base = OpenEHR::Path.parse('/content')
        rest = OpenEHR::Path.parse('/data/value')
        expect((base + rest).to_s).to eq('/content/data/value')
      end

      it 'appends a bare attribute String as a predicate-less segment' do
        base = OpenEHR::Path.parse('/content')
        expect((base + 'data').to_s).to eq('/content/data')
      end
    end

    describe '#descend' do
      it 'splits into the first segment and the remaining path' do
        path = OpenEHR::Path.parse('/content/data/value')
        first, rest = path.descend
        expect(first.attribute).to eq('content')
        expect(rest.to_s).to eq('/data/value')
      end

      it 'returns [nil, self] for the root path' do
        root = OpenEHR::Path.parse('/')
        first, rest = root.descend
        expect(first).to be_nil
        expect(rest).to eq(root)
      end
    end

    context 'node_id predicate (at-code)' do
      it 'parses a plain at-code' do
        segment = OpenEHR::Path.parse('/content[at0001]').segments[0]
        expect(segment.predicate?).to be true
        expect(segment.archetype_node_id).to eq('at0001')
      end

      it 'parses a specialised at-code (e.g. at0001.1)' do
        segment = OpenEHR::Path.parse('/content[at0001.1]').segments[0]
        expect(segment.archetype_node_id).to eq('at0001.1')
      end

      it 'parses a short specialisation-introduced at-code (e.g. at0.2, as used by real ADL 1.4 archetypes for nodes newly added in a specialisation)' do
        segment = OpenEHR::Path.parse('/content[at0.2]').segments[0]
        expect(segment.archetype_node_id).to eq('at0.2')
      end
    end

    context 'node_id predicate (archetype id)' do
      it 'parses a full archetype id as the node_id' do
        segment = OpenEHR::Path.parse('/content[openEHR-EHR-OBSERVATION.blood_pressure.v1]').segments[0]
        expect(segment.archetype_node_id).to eq('openEHR-EHR-OBSERVATION.blood_pressure.v1')
      end
    end

    context 'node_id + name predicate' do
      it "parses [at0004, 'Systolic'] into node_id and name" do
        segment = OpenEHR::Path.parse("/items[at0004, 'Systolic']").segments[0]
        expect(segment.archetype_node_id).to eq('at0004')
        expect(segment.name).to eq('Systolic')
      end

      it "re-emits the name predicate in canonical form" do
        expect(OpenEHR::Path.parse("/items[at0004, 'Systolic']").to_s).to eq("/items[at0004, 'Systolic']")
      end
    end

    context 'invalid paths' do
      it 'rejects a relative path (no leading /)' do
        expect { OpenEHR::Path.parse('content/data') }.to raise_error(OpenEHR::Path::InvalidPathError)
      end

      it 'rejects a wildcard //' do
        expect { OpenEHR::Path.parse('/content//data') }.to raise_error(OpenEHR::Path::InvalidPathError)
      end

      it 'rejects an unclosed predicate bracket' do
        expect { OpenEHR::Path.parse('/content[at0001') }.to raise_error(OpenEHR::Path::InvalidPathError)
      end

      it 'rejects a numeric index predicate' do
        expect { OpenEHR::Path.parse('/content[1]') }.to raise_error(OpenEHR::Path::InvalidPathError)
      end

      it 'rejects a non-String argument' do
        expect { OpenEHR::Path.parse(nil) }.to raise_error(OpenEHR::Path::InvalidPathError)
      end
    end
  end

  describe '.valid?' do
    it 'returns true for a well-formed path' do
      expect(OpenEHR::Path.valid?('/content[at0001]/data')).to be true
    end

    it 'returns false for a malformed path, without raising' do
      expect(OpenEHR::Path.valid?('/content[1]')).to be false
    end
  end
end
