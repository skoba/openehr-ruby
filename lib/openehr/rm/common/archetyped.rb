# This module is based on the UML,
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109318114715_211173_0Report.html
# Ticket refs #65
module OpenEHR
  module RM
    module Common
      module Archetyped
        module LocaterConstants
          CURRENT_TRANSACTION_ID = "current"
          FRAGMENT_SEPARATOR = "#"
          CONTENT_PATH_SEPARATOR = "|"
          ORGANIZER_PATH_SEPARATOR = "/"
          MULTIPART_ID_DELIMITER = "::"
        end

        # Raised by Pathable#item_at_path when a path predicate matches
        # more than one child (e.g. a node_id shared by siblings with
        # different names).
        class PathNotUniqueError < StandardError; end

        class Pathable
          attr_accessor :parent

          # Declares which of this class's attributes are exposed to
          # path navigation, e.g. `path_attribute :data, :state`.
          # Declarations accumulate down the inheritance chain.
          def self.path_attribute(*attr_names)
            @path_attributes ||= []
            @path_attributes.concat(attr_names.map(&:to_sym))
          end

          def self.path_attributes
            own = @path_attributes || []
            self == Pathable ? own : superclass.path_attributes + own
          end

          def initialize(args = { })
            self.parent = args[:parent]
          end

          # The one-level-deep path-navigable children of this node, as
          # {attribute_name_string => value}. Attributes whose value is
          # nil are omitted; a value may itself be an Array (e.g. a
          # CLUSTER's items).
          def path_children
            self.class.path_attributes.each_with_object({}) do |attr, hash|
              value = send(attr)
              hash[attr.to_s] = value unless value.nil?
            end
          end

          def item_at_path(path)
            matches = items_at_path(path)
            case matches.size
            when 0 then nil
            when 1 then matches.first
            else raise PathNotUniqueError, "path #{path} matches #{matches.size} items"
            end
          end

          def items_at_path(path)
            path = self.class.normalize_path(path)
            return [self] if path.root?

            segment, rest = path.descend
            children = path_children[segment.attribute]
            return [] if children.nil?

            matched = self.class.select_by_predicate(Array(children), segment)
            return matched if rest.root?

            matched.flat_map do |child|
              child.is_a?(Pathable) ? child.items_at_path(rest) : []
            end
          end

          def path_exists?(path)
            !items_at_path(path).empty?
          end

          def path_of_item(item)
            find_path_to(item, OpenEHR::Path.new([]))
          end

          def path_unique?(path)
            items_at_path(path).size == 1
          end

          def self.normalize_path(path)
            path.is_a?(OpenEHR::Path) ? path : OpenEHR::Path.parse(path)
          end

          # Filters children matched by a path segment's predicate: a
          # node_id predicate keeps only children whose
          # archetype_node_id matches (non-Locatable children never
          # match a node_id predicate); a name predicate further
          # narrows to the child whose name.value matches.
          def self.select_by_predicate(children, segment)
            return children unless segment.predicate?

            matched = children.select do |child|
              child.respond_to?(:archetype_node_id) &&
                child.archetype_node_id == segment.archetype_node_id
            end
            return matched if segment.name.nil?

            matched.select do |child|
              child.respond_to?(:name) && child.name.respond_to?(:value) &&
                child.name.value == segment.name
            end
          end

          private

          def find_path_to(target, prefix)
            return prefix.to_s if equal?(target)

            self.class.path_attributes.each do |attr|
              value = send(attr)
              next if value.nil?

              siblings = Array(value)
              siblings.each do |child|
                child_prefix = prefix + segment_for(attr, child, siblings)
                if child.equal?(target)
                  return child_prefix.to_s
                elsif child.is_a?(Pathable)
                  found = child.send(:find_path_to, target, child_prefix)
                  return found if found
                end
              end
            end
            nil
          end

          def segment_for(attribute, child, siblings)
            node_id = child.respond_to?(:archetype_node_id) ? child.archetype_node_id : nil
            return OpenEHR::Path::Segment.new(attribute.to_s) if node_id.nil?

            sharing_node_id = siblings.count do |sibling|
              sibling.respond_to?(:archetype_node_id) && sibling.archetype_node_id == node_id
            end
            if sharing_node_id > 1 && child.respond_to?(:name) && child.name.respond_to?(:value)
              OpenEHR::Path::Segment.new(attribute.to_s, archetype_node_id: node_id, name: child.name.value)
            else
              OpenEHR::Path::Segment.new(attribute.to_s, archetype_node_id: node_id)
            end
          end
        end

        class Locatable < Pathable
          include LocaterConstants
          attr_reader :archetype_node_id, :name, :links
          attr_accessor :uid, :archetype_details, :feeder_audit

          def initialize(args = { })
            super(args)
            self.archetype_node_id = args[:archetype_node_id]
            self.name = args[:name]
            self.links = args[:links]
            self.uid = args[:uid]
            self.archetype_details = args[:archetype_details]
            self.feeder_audit = args[:feeder_audit]
          end
          
          def archetype_node_id=(archetype_node_id)
            if archetype_node_id.nil? or archetype_node_id.empty?
              raise ArgumentError, 'archetype_node_id should not be nil'
            end
            @archetype_node_id = archetype_node_id
          end

          def name=(name)
            if name.nil? or name.value.empty?
              raise ArgumentError, 'name should not be empty'
            end
            @name = name
          end

          def links=(links)
            if !links.nil? and links.empty?
              raise ArgumentError, "links shoud not be empty"
            end
            @links = links
          end

          def concept
            if self.is_archetype_root?
              return OpenEHR::RM::DataTypes::Text::DvText.new(:value =>
                                @archetype_details.archetype_id.concept_name)
            else
              raise ArgumentError, 'this is not root'
            end
          end

          def is_archetype_root?
            !archetype_details.nil?
          end
        end

        class Archetyped
          attr_reader :archetype_id, :rm_version
          attr_accessor :template_id

          def initialize(**args)
            self.archetype_id = args[:archetype_id]
            self.rm_version = args[:rm_version]
            self.template_id = args[:template_id]
          end

          def archetype_id=(archetype_id)
            raise ArgumentError, "invalid archetype_id" if archetype_id.nil?
            @archetype_id = archetype_id
          end

          def rm_version=(rm_version)
            if rm_version.nil? or rm_version.empty?
              raise ArgumentError, "invalid rm_version"
            end
            @rm_version = rm_version
          end
        end

        class Link
          attr_reader :meaning, :target, :type
          def initialize(args = { })
            self.meaning = args[:meaning]
            self.target = args[:target]
            self.type = args[:type]
          end
          def meaning=(meaning)
            raise ArgumentError, "meaning should not be nil" if meaning.nil?
            @meaning = meaning
          end
          def target=(target)
            raise ArgumentError, "target should not be nil" if target.nil?
            @target = target
          end
          def type=(type)
            raise ArgumentError, "type should not be nil" if type.nil?
            @type = type
          end
        end # of Link

        class FeederAudit
          attr_reader :originating_system_audit
          attr_accessor :originating_system_item_ids, :feeder_system_audit,
                        :feeder_system_item_ids, :original_content

          def initialize(args = { })
            self.originating_system_audit = args[:originating_system_audit]
            self.originating_system_item_ids = args[:originating_system_item_ids]
            self.feeder_system_audit = args[:feeder_system_audit]
            self.feeder_system_item_ids = args[:feeder_system_item_ids]
            self.original_content = args[:original_content]
          end

          def originating_system_audit=(originating_system_audit)
            if originating_system_audit.nil?
              raise ArgumentError, 'originating_system_audit must be not nil'
            end
            @originating_system_audit = originating_system_audit
          end
        end # of FeederAudit

        class FeederAuditDetails
          attr_reader :system_id
          attr_accessor :provider, :location, :time, :subject, :version_id

          def initialize(args = { })
            self.system_id = args[:system_id]
            self.provider = args[:provider]
            self.location = args[:location]
            self.time = args[:time]
            self.subject = args[:subject]
            self.version_id = args[:version_id]
          end

          def system_id=(system_id)
            if system_id.nil? or system_id.empty?
              raise ArgumentError, 'system_id invalid'
            end
            @system_id = system_id
          end
        end # of FeederAudit_Details
      end # of Archetyped
    end # of Common
  end # of RM
end # OpenEHR
