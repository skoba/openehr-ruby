require 'spec_helper'

describe OpenEHR::Parser::OPTParser do
  let(:opt_file) { File.join(File.dirname(__FILE__), './code_reference_template.opt') }
  let(:parser) { described_class.new(opt_file) }
  let(:code_reference_class) { OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodeReference }

  def fragment(xml)
    doc = Nokogiri::XML::Document.parse(xml)
    doc.remove_namespaces!
    doc.root
  end

  describe 'parsing an OPT containing C_CODE_REFERENCE' do
    def code_reference_from(opt)
      opt.definition.attributes[0].children[0].attributes[0].children[0]
    end

    it 'parses through the type-specific handler without warning' do
      expect { parser.parse }.not_to output.to_stderr
    end

    it 'builds the code reference constraint from the real fragment' do
      result = code_reference_from(parser.parse)

      expect(result).to be_a(code_reference_class)
      expect(result.reference_set_uri).to eq('terminology:http://id.who.int/icd/release/11/mms')
      expect(result.rm_type_name).to eq('CODE_PHRASE')
      expect(result.occurrences.lower).to eq(0)
      expect(result.occurrences.upper).to eq(1)
      expect(result.path).to eq('/category/defining_code')
      expect(result.terminology_id).to be_nil
      expect(result.code_list).to be_nil
      expect(result.any_allowed?).to be(true)
    end
  end

  describe '#c_code_reference' do
    it 'reads the verbatim ProblemList reference-set fragment' do
      node = fragment(<<~XML)
                                            <children xsi:type="C_CODE_REFERENCE">
                                                <rm_type_name>CODE_PHRASE</rm_type_name>
                                                <occurrences>
                                                    <lower_included>true</lower_included>
                                                    <upper_included>true</upper_included>
                                                    <lower_unbounded>false</lower_unbounded>
                                                    <upper_unbounded>false</upper_unbounded>
                                                    <lower>0</lower>
                                                    <upper>1</upper>
                                                </occurrences>
                                                <node_id></node_id>
                                                <referenceSetUri>terminology:http://id.who.int/icd/release/11/mms</referenceSetUri>
                                            </children>
      XML

      result = parser.send(:c_code_reference, node, Node.new)

      expect(result).to be_a(code_reference_class)
      expect(result.reference_set_uri).to eq('terminology:http://id.who.int/icd/release/11/mms')
      expect(result.code_list).to be_nil
      expect(result.terminology_id).to be_nil
      expect(result.path).to eq('/')
    end

    it 'retains inherited terminology and inline code constraints' do
      node = fragment(<<~XML)
        <children xsi:type="C_CODE_REFERENCE">
          <rm_type_name>CODE_PHRASE</rm_type_name>
          <occurrences><lower>0</lower><upper>1</upper></occurrences>
          <terminology_id><value>ICD10</value></terminology_id>
          <code_list>C92</code_list>
          <referenceSetUri>terminology:example</referenceSetUri>
        </children>
      XML

      result = parser.send(:c_code_reference, node, Node.new)

      expect(result.terminology_id.value).to eq('ICD10')
      expect(result.code_list).to eq(['C92'])
    end

    it 'normalizes an empty referenceSetUri to nil without raising' do
      node = fragment(<<~XML)
        <children xsi:type="C_CODE_REFERENCE">
          <rm_type_name>CODE_PHRASE</rm_type_name>
          <occurrences><lower>0</lower><upper>1</upper></occurrences>
          <referenceSetUri></referenceSetUri>
        </children>
      XML

      result = nil
      expect {
        result = parser.send(:c_code_reference, node, Node.new)
      }.not_to raise_error
      expect(result.reference_set_uri).to be_nil
    end
  end
end
