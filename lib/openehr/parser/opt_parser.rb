require 'nokogiri'

module OpenEHR
  module Parser
    class OPTParser < ::OpenEHR::Parser::Base
      TEMPLATE_LANGUAGE_CODE_PATH = '/template/language/code_string'
      TEMPLATE_LANGUAGE_TERM_ID_PATH = '/template/language/terminology_id/value'      
      TEMPLATE_ID_PATH = '/template/template_id/value'
      UID_PATH = '/template/uid/value'
      CONCEPT_PATH = '/template/concept'
      DESC_ORIGINAL_AUTHOR_PATH = '/template/description/original_author'
      DESC_LIFECYCLE_STATE_PATH = '/template/description/lifecycle_state'
      DESC_DETAILS_LANGUAGE_TERM_ID_PATH = '/template/description/details/language/terminology_id/value'
      DESC_DETAILS_LANGUAGE_CODE_PATH = '/template/description/details/language/code_string'
      DESC_DETAILS_PURPOSE_PATH = '/template/description/details/purpose'
      DESC_DETAILS_KEYWORDS_PATH = '/template/description/details/keywords'
      DESC_DETAILS_USE_PATH = '/template/description/details/use'
      DESC_DETAILS_MISUSE_PATH = '/template/description/details/misuse'
      DESC_DETAILS_COPYRIGHT_PATH = '/template/description/details/copyright'
      DEFINITION_PATH = '/template/definition'
      OCCURRENCE_PATH = '/occurrences'
      
      def initialize(filename)
        super(filename)
      end

      def parse
        @opt = Nokogiri::XML::Document.parse(File.open(@filename))
        @opt.remove_namespaces!
        uid = OpenEHR::RM::Support::Identification::UIDBasedID.new(value: text_on_path(@opt, UID_PATH))
        terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(value: text_on_path(@opt,TEMPLATE_LANGUAGE_TERM_ID_PATH))
        language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(code_string: text_on_path(@opt, TEMPLATE_LANGUAGE_CODE_PATH), terminology_id: terminology_id)
        OpenEHR::AM::Template::OperationalTemplate.new(uid: uid, concept: concept, language: language, description: description, template_id: template_id, definition: definition, ontology: ontology)
      end

      private

      def template_id
        OpenEHR::RM::Support::Identification::TemplateID.new(value: text_on_path(@opt, TEMPLATE_ID_PATH))
      end

      def concept
        text_on_path(@opt, CONCEPT_PATH)
      end

      def description
        original_author = text_on_path(@opt, DESC_ORIGINAL_AUTHOR_PATH)
        lifecycle_state = text_on_path(@opt, DESC_LIFECYCLE_STATE_PATH)
        OpenEHR::RM::Common::Resource::ResourceDescription.new(original_author: original_author, lifecycle_state: lifecycle_state, details: [description_details])
      end

      def description_details
        terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(value: text_on_path(@opt, DESC_DETAILS_LANGUAGE_TERM_ID_PATH))
        language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(code_string: text_on_path(@opt, DESC_DETAILS_LANGUAGE_CODE_PATH), terminology_id: terminology_id)
        purpose = text_on_path(@opt, DESC_DETAILS_PURPOSE_PATH)
        keywords = @opt.xpath(DESC_DETAILS_KEYWORDS_PATH).inject([]) {|a, i| a << i.text}
        use = empty_then_nil text_on_path(@opt, DESC_DETAILS_USE_PATH)
        misuse = empty_then_nil text_on_path(@opt, DESC_DETAILS_MISUSE_PATH)
        copyright = empty_then_nil text_on_path(@opt, DESC_DETAILS_COPYRIGHT_PATH)
        OpenEHR::RM::Common::Resource::ResourceDescriptionItem.new(language: language, purpose: purpose, keywords: keywords, use: use, misuse: misuse, copyright: copyright)
      end

      def definition
        root_rm_type = text_on_path(@opt, DEFINITION_PATH + '/rm_type_name')
        root_node = Node.new
        root_node.id = text_on_path(@opt, DEFINITION_PATH + '/node_id')
        root_occurrences = occurrences(@opt.xpath(DEFINITION_PATH + OCCURRENCE_PATH))
        root_archetype_id = OpenEHR::RM::Support::Identification::ArchetypeID.new(value: text_on_path(@opt, DEFINITION_PATH+'/archetype_id/value'))
        root_node.path = "/[#{root_archetype_id.value}]"
        OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot.new(rm_type_name: root_rm_type, node_id: root_node.id, path: root_node.path, occurrences: root_occurrences, archetype_id: root_archetype_id, attributes: attributes(@opt.xpath(DEFINITION_PATH+'/attributes'), root_node))
      end

      def ontology
      end
      
      def children(children_xml, node)
        children_xml.map do |child|
          send child.attributes['type'].text.downcase, child, node
        end
      end

      def c_archetype_root(xml, node = Node.new)
        rm_type_name = text_on_path(xml, './rm_type_name') 
        id = text_on_path(xml, './node_id')
        node.id = id unless id.nil? or id.empty?
        occurrences = occurrences(xml.xpath('./occurrences'))
        archetype_id = OpenEHR::RM::Support::Identification::ArchetypeID.new(value: text_on_path(xml, './archetype_id/value'))
        if node.root? or node.id.nil?
          node.path = "/[#{archetype_id.value}]"
        else
          node.path += "/[#{archetype_id.value}]"
        end
        OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot.new(rm_type_name: rm_type_name, node_id: node.id, path: node.path, occurrences: occurrences, archetype_id: archetype_id, attributes: attributes(xml.xpath('./attributes'), node))
      end

      def c_complex_object(xml, node)
        rm_type_name = xml.xpath('./rm_type_name').text
        node_id = xml.xpath('./node_id').text
        unless node_id.nil? or node_id.empty?
          node.id = node_id
          node.path += "[#{node_id}]"
        end
        OpenEHR::AM::Archetype::ConstraintModel::CComplexObject.new(rm_type_name: rm_type_name, node_id: node.id, path: node.path, occurrences: occurrences(xml.xpath('./occurrences')), attributes: attributes(xml.xpath('./attributes'), node))
      end

      def attributes(attributes_xml, node)
        attributes_xml.map do |attr|
          send attr.attributes['type'].text.downcase, attr, node
        end
      end

      def c_single_attribute(attr_xml, node)
        rm_attribute_name = attr_xml.at('rm_attribute_name').text
        existence = occurrences(attr_xml.at('existence'))
        if node.root?
          path = "/#{rm_attribute_name}"
        elsif node.id
          path = "#{node.path}[#{node.id}]/#{rm_attribute_name}"
        else
          path = "#{node.path}/#{rm_attribute_name}"
        end
        child_node = Node.new(node)
        child_node.path = node.path
        child_node.id = node.id
        OpenEHR::AM::Archetype::ConstraintModel::CSingleAttribute.new(rm_attribute_name: rm_attribute_name, existence: existence, path: path, children: children(attr_xml.xpath('./children'), child_node))
      end

      def c_multiple_attribute(attr_xml, node)
        rm_attribute_name = attr_xml.at('rm_attribute_name').text
        existence = occurrences(attr_xml.at('existence'))
        if node.root?
          path = "/#{rm_attribute_name}"
        elsif node.id
          path = "#{node.path}[#{node.id}]/#{rm_attribute_name}"
        else
          path = "#{node.path}/#{rm_attribute_name}"
        end
        child_node = Node.new(node)
        child_node.path = node.path
        child_node.id = node.id
        OpenEHR::AM::Archetype::ConstraintModel::CMultipleAttribute.new(rm_attribute_name: rm_attribute_name, existence: existence, path: path, children: children(attr_xml.xpath('./children'), child_node))
      end

      def c_code_phrase(attr_xml, node)
        terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(value: attr_xml.at('terminology_id/value').text.strip)
        path = node.path
        code_list = attr_xml.xpath('code_list').text.strip
        occurrences = occurrences(attr_xml.at('occurrences'))
        OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodePhrase.new(terminology_id: terminology_id, code_list: [code_list], path: path, occurrences: occurrences, rm_type_name: 'CodePhrase')
      end

      def archetype_slot(attr_xml,node)
        path = node.path
        node.id = attr_xml.at('node_id').text
        rm_type_name = attr_xml.at('rm_type_name').text
        occurrences = occurrences(attr_xml.at('occurrences'))
        includes_leaf = attr_xml.at('includes')
        includes = assertions(includes_leaf.children, node) if includes_leaf
        excludes_leaf = attr_xml.at('excludes')
        excludes = assertions(excludes_leaf.children, node) if excludes_leaf
        OpenEHR::AM::Archetype::ConstraintModel::ArchetypeSlot.new(path: path, node_id: node.id, rm_type_name: rm_type_name, occurrences: occurrences, includes: includes, excludes: excludes)
      end

      def occurrences(occurrence_xml)
        lower_node = occurrence_xml.at('lower')
        upper_node = occurrence_xml.at('upper')
        lower = lower_node.text.to_i if lower_node
        upper = upper_node.text.to_i if upper_node
        lower_included = to_bool(occurrence_xml.at('lower_included'))
        upper_included = to_bool(occurrence_xml.at('upper_included'))
        OpenEHR::AssumedLibraryTypes::Interval.new(lower: lower, upper: upper, lower_included: lower_included, upper_included: upper_included)
      end

      def constraint_ref(attr_xml, node)
        rm_type_name = attr_xml.at('rm_type_name').text
        reference = attr_xml.at('reference').text
        occurrences = occurrences(attr_xml.at('occurrences'))
        OpenEHR::AM::Archetype::ConstraintModel::ConstraintRef.new(rm_type_name: rm_type_name, occurrences: occurrences, reference: reference)
      end

      def assertions(attr_xml, node)
        string_expression = attr_xml.at('string_expression')
        string_expression = string_expression.nil? ? nil : string_expression.text
        expression_leaf = attr_xml.at 'expression'
        expression = send expression_leaf.attributes['type'].text.downcase, expression_leaf
        [OpenEHR::AM::Archetype::Assertion::Assertion.new(expression: expression, string_expression: string_expression)]
      end

      def expr_binary_operator(attr_xml)
        type = attr_xml.at('type').text
        operator = OpenEHR::AM::Archetype::Assertion::OperatorKind.new(value: attr_xml.at('operator').text.to_i)

        precedence_overridden = attr_xml.at('precedence_overridden').text == 'true' ? true : false
        right_operand_leaf = attr_xml.at 'right_operand'
        right_operand = send right_operand_leaf.attributes['type'].text.downcase, right_operand_leaf
        left_operand_leaf = attr_xml.at 'left_operand'
        left_operand = send left_operand_leaf.attributes['type'].text.downcase, left_operand_leaf
        OpenEHR::AM::Archetype::Assertion::ExprBinaryOperator.new(type: type, operator: operator, precedence_overridden: precedence_overridden, right_operand: right_operand, left_operand: left_operand)
      end

      def expr_leaf(attr_xml)
        type = attr_xml.at('type').text
        item_leaf = attr_xml.at('item')
        item = send type.downcase, item_leaf
        reference_type = attr_xml.at('reference_type').text
        OpenEHR::AM::Archetype::Assertion::ExprLeaf.new(type: type, item: item, reference_type: reference_type)
      end

      def c_primitive_object(attr_xml, node)
        rm_type_name = attr_xml.at('rm_type_name').text
        occurrences = occurrences(attr_xml.at('occurrences'))
        OpenEHR::AM::Archetype::ConstraintModel::CPrimitiveObject.new(rm_type_name: rm_type_name, occurrences: occurrences, node_id: node.id)
      end
      
      def c_string(attr_xml)
        pattern = attr_xml.at('pattern').text
        OpenEHR::AM::Archetype::ConstraintModel::Primitive::CString.new(pattern: pattern)
      end

      def c_dv_quantity(attr_xml, node)
        rm_type_name = attr_xml.at('rm_type_name').text
        occurrences = occurrences(attr_xml.at('occurrences'))
        property_terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(value: attr_xml.at('property/terminology_id/value').text)
        property_code_string = attr_xml.at('property/code_string').text
        property = OpenEHR::RM::DataTypes::Text::CodePhrase.new(terminology_id: property_terminology_id, code_string: property_code_string)
        list = attr_xml.xpath('.//list').map do |element|
          units = element.at('units').text if element.at('units')
          magnitude = occurrences(element.at('magnitude')) if element.at('magnitude')
          precision = occurrences(element.at('precision')) if element.at('precision')
          OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CQuantityItem.new(magnitude: magnitude, precision: precision, units: units)
        end
        OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvQuantity.new(rm_type_name: rm_type_name, occurrences: occurrences, list: list, property: property)
      end

      def string(attr_xml)
        attr_xml.text
      end

      def empty_then_nil(val)
        if val.empty?
          return nil
        else
          return val
        end
      end

      def text_on_path(xml, path)
        xml.xpath(path).text
      end

      def to_bool(str)
        if str =~ /true/i
          return true
        elsif str =~ /false/i
          return false
        end
        return nil
      end
    end
  end
end

class Node
  attr_accessor :id, :path
  attr_reader :parent

  def initialize(parent = nil)
    @parent = parent
    @path = '/' if parent.nil?
  end

  def root?
    parent.nil?
  end
end
