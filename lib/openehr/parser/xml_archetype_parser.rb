require 'nokogiri'
require_relative 'xml_constraint_parsing'
require_relative 'xml_primitive_parsing'
require_relative 'xml_domain_type_parsing'

module OpenEHR
  module Parser
    # Reads the canonical openEHR ITS-XML archetype shape that
    # XMLSerializer (lib/openehr/serializer/xml_serializer.rb) emits -
    # see that file's header comment for how that shape was established
    # as ground truth. Mirrors ADLParser#archetype's construction
    # pattern (a small constructor-argument method per Archetype.new
    # keyword) and shares the same <definition> constraint-tree readers
    # as OPTParser via the 3 modules extracted in B3
    # (xml_constraint_parsing/xml_primitive_parsing/xml_domain_type_parsing).
    class XMLArchetypeParser < ::OpenEHR::Parser::Base
      include XMLConstraintParsing
      include XMLPrimitiveParsing
      include XMLDomainTypeParsing

      def parse
        archetype
      rescue OpenEHR::Parser::ParseError
        raise
      rescue StandardError => e
        raise OpenEHR::Parser::ParseError, "invalid XML archetype (#{@filename}): #{e.class}: #{e.message}"
      end

      private

      def doc
        @doc ||= begin
          parsed = File.open(@filename, 'rb:bom|utf-8') do |file|
            Nokogiri::XML::Document.parse(file, options: SAFE_PARSE_OPTIONS)
          end
          parsed.remove_namespaces!
          parsed
        end
      end

      def root
        @root ||= doc.at('archetype')
      end

      def text_on_path(xml, path)
        node = xml.at(path)
        node.nil? ? nil : node.text
      end

      def code_phrase_from(node)
        return nil if node.nil?

        terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(value: text_on_path(node, 'terminology_id/value'))
        OpenEHR::RM::DataTypes::Text::CodePhrase.new(terminology_id: terminology_id, code_string: text_on_path(node, 'code_string'))
      end

      # Nodes emitted with an 'id' attribute keying a plain text value
      # (original_author/other_details/author/original_resource_uri) -
      # the same shape everywhere it's used, so read generically.
      def id_keyed_hash(nodes)
        return nil if nodes.empty?

        nodes.each_with_object({}) { |n, hash| hash[n['id']] = n.text }
      end

      def archetype_id
        OpenEHR::RM::Support::Identification::ArchetypeID.new(value: text_on_path(root, 'archetype_id/value'))
      end

      def uid
        value = text_on_path(root, 'uid/value')
        value.nil? ? nil : OpenEHR::RM::Support::Identification::HierObjectID.new(value: value)
      end

      def adl_version
        text_on_path(root, 'adl_version')
      end

      def parent_archetype_id
        value = text_on_path(root, 'parent_archetype_id/value')
        value.nil? ? nil : OpenEHR::RM::Support::Identification::ArchetypeID.new(value: value)
      end

      def concept
        text_on_path(root, 'concept')
      end

      def original_language
        code_phrase_from(root.at('original_language'))
      end

      def translations
        translations_node = root.at('translations')
        return nil if translations_node.nil?

        translations_node.xpath('translation').each_with_object({}) do |node, hash|
          hash[node['language']] = translation_details(node)
        end
      end

      def translation_details(node)
        OpenEHR::RM::Common::Resource::TranslationDetails.new(
          language: code_phrase_from(node.at('language')),
          author: id_keyed_hash(node.xpath('author')),
          accreditation: text_on_path(node, 'accreditation'),
          other_details: id_keyed_hash(node.xpath('other_details'))
        )
      end

      def description
        node = root.at('description')
        return nil if node.nil?

        OpenEHR::RM::Common::Resource::ResourceDescription.new(
          original_author: id_keyed_hash(node.xpath('original_author')),
          other_contributors: description_other_contributors(node),
          lifecycle_state: text_on_path(node, 'lifecycle_state'),
          details: description_details(node)
        )
      end

      def description_other_contributors(node)
        contributors = node.xpath('other_contributors').map(&:text)
        contributors.empty? ? nil : contributors
      end

      def description_details(node)
        node.xpath('details/detail').each_with_object({}) do |detail, hash|
          hash[detail['language']] = description_detail_item(detail)
        end
      end

      def description_detail_item(node)
        keywords = node.xpath('keywords').map(&:text)
        OpenEHR::RM::Common::Resource::ResourceDescriptionItem.new(
          language: code_phrase_from(node.at('language')),
          purpose: text_on_path(node, 'purpose'),
          keywords: keywords.empty? ? nil : keywords,
          use: text_on_path(node, 'use'),
          misuse: text_on_path(node, 'misuse'),
          copyright: text_on_path(node, 'copyright'),
          original_resource_uri: id_keyed_hash(node.xpath('original_resource_uri')),
          other_details: id_keyed_hash(node.xpath('other_details'))
        )
      end

      # Unlike OPTParser (whose top-level definition is a
      # CArchetypeRoot, read via c_archetype_root, which has its own
      # root-path override), a standalone archetype's <definition> root
      # is a plain CComplexObject. c_complex_object (shared with
      # OPTParser) always appends [node_id] to the path it's handed,
      # which is correct for every *nested* complex object it's called
      # on via attributes()/children() but wrong for the root itself
      # (whose path must stay "/") - so the root is built directly here
      # instead, mirroring c_archetype_root's override.
      def definition
        xml = root.at('definition')
        node = Node.new
        rm_type_name = text_on_path(xml, './rm_type_name')
        node_id = text_on_path(xml, './node_id')
        node.id = node_id unless node_id.nil? || node_id.empty?
        node.path = '/'
        OpenEHR::AM::Archetype::ConstraintModel::CComplexObject.new(
          rm_type_name: rm_type_name, node_id: node.id, path: node.path,
          occurrences: occurrences(xml.xpath('./occurrences')), attributes: attributes(xml.xpath('./attributes'), node)
        )
      end

      def invariants
        node = root.at('invariants')
        return nil if node.nil?

        node.xpath('invariant').map { |invariant| invariant_assertion(invariant) }
      end

      def invariant_assertion(node)
        assertions(node, Node.new).first
      end

      def ontology
        node = root.at('ontology')
        OpenEHR::AM::Archetype::Ontology::ArchetypeOntology.new(
          primary_language: text_on_path(node, 'primary_language'),
          specialisation_depth: ontology_specialisation_depth(node),
          languages_available: ontology_string_list(node, 'languages_available'),
          terminologies_available: ontology_string_list(node, 'terminologies_available'),
          term_definitions: ontology_term_definitions(node, 'term_definitions'),
          constraint_definitions: ontology_optional_term_definitions(node, 'constraint_definitions'),
          term_bindings: ontology_bindings(node, 'term_bindings') { |value| [code_phrase_from_binding(value)] },
          constraint_bindings: ontology_bindings(node, 'constraint_bindings') { |value| OpenEHR::RM::DataTypes::URI::DvUri.new(value: value) }
        )
      end

      def ontology_specialisation_depth(node)
        value = text_on_path(node, 'specialisation_depth')
        value.nil? ? nil : value.to_i
      end

      def ontology_string_list(node, keyword)
        values = node.xpath(keyword).map(&:text)
        values.empty? ? nil : values
      end

      def ontology_term_definitions(node, keyword)
        node.xpath(keyword).each_with_object({}) do |term_node, by_lang|
          lang = term_node['language']
          (by_lang[lang] ||= {})[term_node['code']] = archetype_term(term_node)
        end
      end

      def ontology_optional_term_definitions(node, keyword)
        result = ontology_term_definitions(node, keyword)
        result.empty? ? nil : result
      end

      def archetype_term(term_node)
        items = term_node.xpath('items').each_with_object({}) { |item, hash| hash[item['id']] = item.text }
        OpenEHR::AM::Archetype::Ontology::ArchetypeTerm.new(code: term_node['code'], items: items)
      end

      def ontology_bindings(node, keyword)
        result = node.xpath(keyword).each_with_object({}) do |binding_node, by_terminology|
          terminology = binding_node['terminology']
          (by_terminology[terminology] ||= {})[binding_node['code']] = yield(binding_node.text)
        end
        result.empty? ? nil : result
      end

      # term_bindings' value is a "terminology::code" qualified
      # reference (matching ADLSerializer/XMLSerializer's own emission),
      # not a bare code - split it back into a CodePhrase.
      def code_phrase_from_binding(value)
        terminology, code = value.split('::', 2)
        OpenEHR::RM::DataTypes::Text::CodePhrase.new(
          terminology_id: OpenEHR::RM::Support::Identification::TerminologyID.new(value: terminology),
          code_string: code
        )
      end

      def archetype
        OpenEHR::AM::Archetype::Archetype.new(
          archetype_id: archetype_id,
          adl_version: adl_version,
          uid: uid,
          concept: concept,
          original_language: original_language,
          translations: translations,
          description: description,
          definition: definition,
          ontology: ontology,
          parent_archetype_id: parent_archetype_id,
          invariants: invariants
        )
      end
    end
  end
end
