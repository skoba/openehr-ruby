# This module is an implementation of this UML:
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109331021343_528780_2066Report.html
# Ticket refs #39
module OpenEHR
  module RM
    module Support
      module Identification
        class ObjectID
          attr_reader :value

          def initialize(args = {})
            self.value=args[:value]
          end

          def value=(value)
            raise ArgumentError, "empty value" if value.nil? or value.empty?
            @value = value            
          end

          def ==(object_id)
            self.value == object_id.value
          end
        end # of ObjectID

        class ObjectRef
          attr_reader :namespace, :type, :id

          def initialize(args = {})
            self.namespace = args[:namespace]
            self.type = args[:type]
            self.id = args[:id]
          end

          def namespace=(namespace)
            if namespace.nil? or namespace.empty? or 
                !(/^[a-zA-Z][a-zA-Z0-9_\-\:\/\&\+\?]*$/ =~ namespace)
              raise ArgumentError
            end
            @namespace = namespace
          end

          def type=(type)
            raise ArgumentError if type.nil? or type.empty?
            @type = type
          end

          def id=(id)
            raise ArgumentError if id.nil?
            @id = id
          end
        end

        class ArchetypeID < ObjectID
          attr_reader :rm_originator, :rm_name, :rm_entity,
                      :concept_name, :specialisation, :version_id
          
          def initialize(args = {})
            if args[:value].nil?
              self.rm_originator = args[:rm_originator]
              self.rm_name = args[:rm_name]
              self.rm_entity = args[:rm_entity]
              self.concept_name = args[:concept_name]
              self.version_id = args[:version_id]
              self.specialisation = args[:specialisation]
            else
              super(args)
            end
          end

          def value=(value)
            if /([a-zA-Z]\w+)-([a-zA-Z]\w+)-([a-zA-Z]\w+)\.([a-zA-Z]\w+)(-([a-zA-Z]\w+))?\.(v[1-9]\d*)/ =~ value
              self.rm_originator = $1
              self.rm_name = $2
              self.rm_entity = $3
              self.concept_name = $4
              self.specialisation = $6
              self.version_id = $7
            else
              raise ArgumentError, 'invalid archetype id form'
            end
          end

          def qualified_rm_entity
            return @rm_originator + '-' + @rm_name + '-' + @rm_entity
          end

          def domain_concept
            if @specialisation.nil?
              return @concept_name
            else
              return @concept_name + '-' + @specialisation
            end
          end

          def value
            return self.qualified_rm_entity + '.' +
              self.domain_concept + '.' + @version_id
          end

          def concept_name=(concept_name)
            if concept_name.nil? or concept_name.empty?
              raise ArgumentError, 'concept_name is mandatory'
            end
            @concept_name = concept_name
          end

          def domain_concept=(domain_concept)
            if domain_concept.nil? or domain_concept.empty?
              raise ArgumentError, "domain concept not valid"
            end
            if /([a-zA-Z]\w+)(-([a-zA-Z]\w))?/ =~ domain_concept
              self.concept_name = $1
              self.specialisation = $3
            else
              raise ArgumentError, 'invalid domain concept form'
            end
          end

          def rm_name=(rm_name)
            raise ArgumentError, "rm_name not valid" if rm_name.nil? or rm_name.empty?
            @rm_name = rm_name
          end

          def rm_entity=(rm_entity)
            if rm_entity.nil? or rm_entity.empty?
              raise ArgumentError, "rm_entity is mandatory"
            end
            @rm_entity = rm_entity
          end

          def rm_originator=(rm_originator)
            if rm_originator.nil? or rm_originator.empty?
              raise ArgumentError, "rm_originator not valid"
            end
            @rm_originator = rm_originator
          end

          def specialisation=(specialisation)
            if !specialisation.nil? and specialisation.empty?
              raise ArgumentError, "rm_specialisation not valid" 
            end
            @specialisation = specialisation
          end

          def version_id=(version_id)
            raise ArgumentError, "version_id not valid" if version_id.nil? or version_id.empty?
            @version_id = version_id
          end
        end

        class TerminologyID < ObjectID
          attr_reader :name, :version_id

          def initialize(args = {})
            if args[:value].nil?
              self.name = args[:name]
              self.version_id = args[:version_id]
            else
              super(args)
            end
          end

          def value
            if @version_id.empty?
              @name
            else
              @name + '(' + @version_id + ')'
            end 
          end


          def value=(value)
            raise ArgumentError, "value not valid" if value.nil? or value.empty?
            if /(.*)\((.*)\)/ =~ value
              self.name = $1
              self.version_id = $2
            else
              self.name = value
              self.version_id = ''
            end
          end

          def name=(name)
            raise ArgumentError, "name not valid" if name.nil? or name.empty?
            @name = name
          end

          def version_id=(version_id)
            if version_id.nil?
              @version_id = ''
            else
              @version_id = version_id
            end
          end
        end # of Terminology_ID

        class GenericID < ObjectID
          attr_reader :scheme

          def initialize(args)
            super(args)
            self.scheme = args[:scheme]
          end

          def scheme=(scheme)
            if scheme.nil? or scheme.empty?
              raise ArgumentError, "scheme not valid"
            end
            @scheme = scheme
          end
        end # of Generic_ID

        class TemplateID < ObjectID

        end

        class UIDBasedID < ObjectID
          attr_reader :root, :extension

          def initialize(args = {})
            super(args)
          end

          def value=(value)
            super(value)
            if /(\S+)::(\S+)/ =~ value
              @root = UID.new(:value => $1)
              @extension = $2
            else
              @root = UID.new(:value => value)
              @extension = ''
            end
          end

          def has_extension?
            return !@extension.empty?
          end
        end

        class ObjectVersionID < UIDBasedID
          attr_reader :object_id, :creating_system_id, :version_tree_id

          def initialize(args= {})
            super(args)
          end

          def value=(value)
            if /^(\S+)::(\S+)::((\d|\.)+)$/ =~ value
              self.object_id = UID.new(:value => $1)
              self.creating_system_id = UID.new(:value => $2)
              self.version_tree_id = VersionTreeID.new(:value => $3)
            else
              raise ArgumentError, 'invalid format'
            end
          end

          def value
            return @object_id.value + '::' + 
              @creating_system_id.value + '::' +
              @version_tree_id.value
          end

          def object_id=(object_id)
            raise ArgumentError, 'object_id is mandatory' if object_id.nil?
            @object_id = object_id
          end

          def creating_system_id=(creating_system_id)
            if creating_system_id.nil?
              raise ArgumentError, 'creating_system_id is mandatory'
            end
            @creating_system_id = creating_system_id
          end

          def version_tree_id=(version_tree_id)
            if version_tree_id.nil?
              raise ArgumentError, 'version_tree_id is mandatory'
            end
            @version_tree_id = version_tree_id
          end

          def is_branch?
            return @version_tree_id.is_branch?
          end
        end

        class LocatableRef < ObjectRef
          attr_reader :path

          def initialize(args = {})
            super(args)
            self.path = args[:path]
          end

          def path=(path)
            raise ArgumentError if path.nil? or path.empty?
            @path = path
          end

          def as_uri
            'ehr://' + @id.value + '/' + @path
          end
        end

        class PartyRef < ObjectRef
          def type=(type)
            parties = %w[PERSON ORGANISATION GROUP AGENT ROLE PARTY ACTOR]
            raise ArgumentError, 'type invalid' unless parties.include? type
            @type = type
          end
        end

        class AccessGroupRef < ObjectRef
          def initialize(args = {})
            super(args)
            @type = 'ACCESS_GROUP'
          end

          def type=(type)
          end
        end

        class HierObjectID < UIDBasedID

        end

        class VersionTreeID
          attr_reader :trunk_version, :branch_number, :branch_version

          def initialize(args = {})
            self.value = args[:value]
          end

          def value=(value)
            raise ArgumentError, 'value invalid' if value.nil? or value.empty?
            (trunk_version, branch_number, branch_version) = value.split '.'
            self.trunk_version = trunk_version
            self.branch_number = branch_number
            self.branch_version = branch_version
          end

          def value
            @value = trunk_version
            @value = @value + '.' + @branch_number unless @branch_number.nil?
            @value = @value + '.' + @branch_version unless @branch_version.nil?
            return @value
          end

          def trunk_version=(trunk_version)
            if trunk_version.nil? || (trunk_version.to_i < 1)
              raise ArgumentError, 'trunk_version invalid'
            end
            @trunk_version = trunk_version
          end

          def branch_number=(branch_number)
            unless branch_number.nil? or branch_number.to_i >= 1
              raise ArgumentError, 'branch number invalid'
            end
            @branch_number = branch_number
          end

          def branch_version=(branch_version)
            if (!branch_version.nil? and !(branch_version.to_i >= 1)) or
                (!branch_version.nil? and @branch_number.nil?)
              raise ArgumentError, 'branch version invalid'
            end
            @branch_version = branch_version
          end

          def is_branch?
            !@branch_version.nil? and !@branch_number.nil?
          end

          def is_first?
            trunk_version == '1'
          end
        end

        class UID
          attr_reader :value

          def initialize(args = {})
            self.value = args[:value]
          end

          def value=(value)
            raise ArgumentError if value.nil? or value.empty?
            @value = value
          end
        end

        class UUID < UID

        end

        class InternetID <UID
          
        end

        class IsoOID <UID

        end        
      end # of Identification
    end # of Support
  end # of RM
end # of OpenEHR
