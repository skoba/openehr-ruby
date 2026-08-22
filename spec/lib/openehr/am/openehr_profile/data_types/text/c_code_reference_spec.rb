require 'spec_helper'

describe OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodeReference do
  let(:occurrences) do
    OpenEHR::AssumedLibraryTypes::Interval.new(
      lower: 0, upper: 1, lower_included: true, upper_included: true
    )
  end
  let(:args) do
    {
      rm_type_name: 'CODE_PHRASE', occurrences: occurrences,
      reference_set_uri: 'terminology:http://id.who.int/icd/release/11/mms'
    }
  end
  let(:code_reference) { described_class.new(args) }

  it 'is a kind of CCodePhrase' do
    expect(code_reference).to be_a(OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodePhrase)
  end

  it 'keeps its reference set URI' do
    expect(code_reference.reference_set_uri).to eq('terminology:http://id.who.int/icd/release/11/mms')
  end

  it 'rejects an empty reference set URI' do
    expect { described_class.new(args.merge(reference_set_uri: '')) }.to raise_error(ArgumentError)
  end

  it 'allows a nil reference set URI for tolerant parsing' do
    expect { described_class.new(args.merge(reference_set_uri: nil)) }.not_to raise_error
  end

  it 'requires occurrences through the inherited constraint validation' do
    expect { described_class.new(args.merge(occurrences: nil)) }.to raise_error(ArgumentError)
  end

  it 'remains permissive when only a reference set URI is present' do
    expect(code_reference.any_allowed?).to be(true)
    expect(code_reference.valid_value?('C92')).to be(true)
  end

  it 'retains inherited inline code-list enforcement when supplied' do
    constrained = described_class.new(args.merge(code_list: ['C92']))

    expect(constrained.valid_value?('Z00')).to be(false)
  end
end
