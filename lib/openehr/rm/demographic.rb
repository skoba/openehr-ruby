# This module is based on the UML,
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_5_76d0249_1118674798473_6021_0Report.html
# Ticket refs #45
require_relative 'common/archetyped'

module OpenEHR
  module RM
    module Demographic
      class Party < OpenEHR::RM::Common::Archetyped::Locatable
        attr_reader :uid, :identities, :contacts, :relationships,
                    :reverse_relationships
        attr_accessor :details
        alias :type :name

        def initialize(args = { })
          super(args)
          self.uid = args[:uid]
          self.identities = args[:identities]
          self.contacts = args[:contacts]
          self.relationships = args[:relationships]
          self.reverse_relationships =
            args[:reverse_relationships]
          self.details = args[:details]
        end

        def uid=(uid)
          raise ArgumentError, 'uid is mandatory' if uid.nil?
          @uid = uid
        end

        def identities=(identities)
          if identities.nil? || identities.empty?
            raise ArgumentError, 'identities are mandatory'
          end
          @identities = identities
        end

        def contacts=(contacts)
          if !contacts.nil? && contacts.empty?
            raise ArgumentError, 'contacts should not be empty'
          end
          @contacts = contacts
        end

        def parent=(parent)
          @parent = nil
        end

        def relationships=(relationships)
          unless relationships.nil?
            if relationships.empty?
              raise ArgumentError, 'relationships should not be empty?'
            else
              relationships.each do |rel|
                if rel.source.id.value != @uid.value
                  raise ArgumentError, 'invalid source of relationships'
                end
              end
            end
          end
          @relationships = relationships
        end

        def reverse_relationships=(reverse_relationships)
          if !reverse_relationships.nil? && reverse_relationships.empty?
            raise ArgumentError, 'reverse_relationships should not be empty'
          end
          @reverse_relationships = reverse_relationships
        end
      end

      class PartyIdentity < OpenEHR::RM::Common::Archetyped::Locatable
        attr_reader :details

        def initialize(args = { })
          super(args)
          self.details = args[:details]
        end

        def details=(details)
          if details.nil?
            raise ArgumentError, 'details are mandatory'
          end
          @details = details
        end

        def purpose
          return @name
        end
      end

      class Contact < OpenEHR::RM::Common::Archetyped::Locatable
        attr_accessor :time_validity
        attr_reader :addresses

        def initialize(args = { })
          super(args)
          self.addresses = args[:addresses]
          self.time_validity = args[:time_validity]
        end

        def purpose
          return @name
        end

        def addresses=(addresses)
          if addresses.nil? || addresses.empty?
            raise ArgumentError, 'address is mandatory'
          end
          @addresses = addresses
        end
      end

      class Address < OpenEHR::RM::Common::Archetyped::Locatable
        attr_reader :details

        def initialize(args = { })
          super(args)
          self.details = args[:details]
        end

        def details=(details)
          if details.nil?
            raise ArgumentError, 'details are mandatory'
          end
          @details = details
        end

        def type
          return @name
        end
      end

      class Actor < Party
        LEAGAL_IDENTITY = 'legal identity'
        attr_reader :languages, :roles

        def initialize(args = { })
          super(args)
          self.roles = args[:roles]
          self.languages = args[:languages]
        end

        def roles=(roles)
          if !roles.nil? && roles.empty?
            raise ArgumentError, 'roles should not be empty'
          end
          @roles = roles
        end

        def has_legal_identity?
          @identities.each do |identity|
            if identity.purpose.value == LEAGAL_IDENTITY
              return true
            end
          end
          return false
        end

        def languages=(languages)
          if !languages.nil? && languages.empty?
            raise ArgumentError, 'languages should not be empty.'
          end
          @languages = languages
        end
      end

      class Person < Actor

      end

      class Organisation < Actor

      end

      class Group < Actor

      end

      class Agent < Actor

      end

      class Role < Party
        attr_reader :performer, :capabilities
        attr_accessor :time_validity

        def initialize(args = { })
          super(args)
          self.performer = args[:performer]
          self.capabilities = args[:capabilities]
          self.time_validity = args[:time_validity]
        end

        def performer=(performer)
          if performer.nil?
            raise ArgumentError, 'performer is mandatory'
          end
          @performer = performer
        end

        def capabilities=(capabilities)
          if !capabilities.nil? && capabilities.empty?
            raise ArgumentError, 'capability should not be empty'
          end
          @capabilities = capabilities
        end
      end

      class Capability < OpenEHR::RM::Common::Archetyped::Locatable
        attr_reader :credentials
        attr_accessor :time_validity

        def initialize(args = { })
          super(args)
          self.credentials = args[:credentials]
          self.time_validity = args[:time_validity]
        end

        def credentials=(credentials)
          if credentials.nil?
            raise ArgumentError, 'credentials are mandatory'
          end
          @credentials = credentials
        end
      end

      class PartyRelationship < OpenEHR::RM::Common::Archetyped::Locatable
        attr_accessor :details, :time_validity
        attr_reader :source, :target
        alias :type :name

        def initialize(args = { })
          super(args)
          self.uid = args[:uid]
          self.details = args[:details]
          self.time_validity = args[:time_validity]
          self.source = args[:source]
          self.target = args[:target]
        end

        def uid=(uid)
          if uid.nil?
            raise ArgumentError, 'uid is mandatory'
          end
          @uid = uid
        end

        def source=(source)
          if source.nil? or source.id.value != @uid.value
            raise ArgumentError, 'source is invalid'
          end
          @source = source
        end

        def target=(target)
          if target.nil?
            raise ArgumentError, 'taraget is invalid'
          end
          @target = target
        end
      end

      class VersionedParty < OpenEHR::RM::Common::Archetyped::Locatable

      end
    end # of Demographic
  end # of RM
end # of OpenEHR
