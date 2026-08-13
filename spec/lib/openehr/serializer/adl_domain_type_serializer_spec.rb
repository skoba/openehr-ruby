require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../adl_parser/parser_spec_helper'
require 'tempfile'
include OpenEHR::Serializer
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::OpenEHRProfile::DataTypes::Text
include OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
include OpenEHR::AM::OpenEHRProfile::DataTypes::Basic
include OpenEHR::AssumedLibraryTypes
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataTypes::Quantity
include OpenEHR::RM::DataTypes::Text

describe 'ADLSerializer C_DV_QUANTITY (cADL domain type emitter)' do
  let(:mandatory) { Interval.new(:lower => 1, :upper => 1, :lower_included => true, :upper_included => true) }

  def serializer_for(definition)
    archetype = double('archetype', :definition => definition)
    ADLSerializer.new(archetype)
  end

  def value_attribute(child)
    CSingleAttribute.new(:rm_attribute_name => 'value', :existence => mandatory, :children => [child])
  end

  def wrapped_definition(child)
    node = CComplexObject.new(:rm_type_name => 'DV_QUANTITY', :node_id => 'at0000', :occurrences => mandatory,
                              :attributes => [value_attribute(child)])
    serializer_for(node).definition
  end

  def code_phrase(terminology, code)
    CodePhrase.new(:terminology_id => TerminologyID.new(:value => terminology), :code_string => code)
  end

  describe 'any_allowed' do
    it 'emits an empty constraint' do
      node = CDvQuantity.new(:rm_type_name => 'DvQuantity', :occurrences => mandatory)
      expect(wrapped_definition(node)).to include('value matches {C_DV_QUANTITY < >}')
    end
  end

  describe 'a fully specified constraint' do
    let(:property) { code_phrase('openehr', '128') }
    let(:list) do
      [CQuantityItem.new(:rm_type_name => 'DvQuantity', :occurrences => mandatory, :units => 'yr',
                         :magnitude => Interval.new(:lower => 0.0, :upper => 200.0),
                         :precision => Interval.new(:lower => 2, :upper => 2)),
       CQuantityItem.new(:rm_type_name => 'DvQuantity', :occurrences => mandatory, :units => 'mth',
                         :magnitude => Interval.new(:lower => 1.0, :upper => 36.0),
                         :precision => Interval.new(:lower => 2, :upper => 2))]
    end
    let(:assumed_value) { DvQuantity.new(:units => 'yr', :magnitude => 8.0, :precision => 2) }
    let(:node) do
      CDvQuantity.new(:rm_type_name => 'DvQuantity', :occurrences => mandatory,
                      :property => property, :list => list, :assumed_value => assumed_value)
    end

    it 'emits the property as a qualified term code reference' do
      expect(wrapped_definition(node)).to include('property = <[openehr::128]>')
    end

    it 'emits each list item keyed by 1-based position' do
      text = wrapped_definition(node)
      expect(text).to include('["1"] = <')
      expect(text).to include('units = <"yr">')
      expect(text).to include('magnitude = <|0.0..200.0|>')
      expect(text).to include('precision = <|2|>')
      expect(text).to include('["2"] = <')
      expect(text).to include('units = <"mth">')
      expect(text).to include('magnitude = <|1.0..36.0|>')
    end

    it 'emits the assumed_value as a plain (non-range) magnitude/precision' do
      text = wrapped_definition(node)
      expect(text).to include('assumed_value = <')
      expect(text).to include('units = <"yr">')
      expect(text).to include('magnitude = <8.0>')
      expect(text).to include('precision = <2>')
    end

    it 'round-trips through the real ADL grammar' do
      text = wrapped_definition(node)
      archetype_text = <<~ADL
        archetype
            adl-test-ENTRY.round_trip_c_dv_quantity.v1

        concept
            [at0000]

        language
            original_language = <[ISO_639-1::en]>

        #{text}

        ontology
            primary_language = <"en">
            languages_available = <"en", ...>
            term_definitions = <
                ["en"] = <
                    items = <
                        ["at0000"] = <
                            text = <"round trip test">
                            description = <"round trip test">
                        >
                    >
                >
            >
      ADL

      tempfile = Tempfile.new(['cdvquantity_roundtrip', '.adl'])
      tempfile.write(archetype_text)
      tempfile.close
      begin
        reparsed = OpenEHR::Parser::ADLParser.new(tempfile.path).parse
        reparsed_node = reparsed.definition.attributes.first.children.first

        expect(reparsed_node).to be_an_instance_of(CDvQuantity)
        expect(reparsed_node.property.terminology_id.value).to eq('openehr')
        expect(reparsed_node.property.code_string).to eq('128')
        expect(reparsed_node.list.size).to eq(2)
        expect(reparsed_node.list.first.units).to eq('yr')
        expect(reparsed_node.assumed_value.units).to eq('yr')
        expect(reparsed_node.assumed_value.magnitude).to eq(8.0)
        expect(reparsed_node.assumed_value.precision).to eq(2)
      ensure
        tempfile.unlink
      end
    end
  end

  describe 'unsupported ADL 1.4 domain types' do
    it 'raises a clear ArgumentError for C_DV_SCALE (no ADL 1.4 grammar rule)' do
      node = CDvScale.new(:rm_type_name => 'DvScale', :occurrences => mandatory)
      expect { wrapped_definition(node) }.to raise_error(ArgumentError, /C_DV_SCALE/)
    end

    it 'raises a clear ArgumentError for C_DV_STATE (no ADL 1.4 grammar rule)' do
      state_machine = StateMachine.new(:states => [TerminalState.new(:name => 'done')])
      node = CDvState.new(:rm_type_name => 'DvState', :occurrences => mandatory, :value => state_machine)
      expect { wrapped_definition(node) }.to raise_error(ArgumentError, /C_DV_STATE/)
    end
  end
end
