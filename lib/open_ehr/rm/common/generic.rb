# This module is a implementation of the bellow UML
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_5_1_76d0249_1140169202660_257304_813Report.html
# Related to the ticket #62
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataTypes::Basic
module OpenEHR
  module RM
    module Common
      module Generic
        class AuditDetails
          attr_reader :system_id, :committer, :time_committed, :change_type
          attr_accessor :description

          def initialize(args = { })
            self.system_id = args[:system_id]
            self.committer = args[:committer]
            self.time_committed = args[:time_committed]
            self.change_type = args[:change_type]
            self.description = args[:description]
          end

          def system_id=(system_id)
            if system_id.nil? or system_id.empty?
              raise ArgumentError, 'system_id is mandatory'
            end
            @system_id = system_id
          end

          def committer=(committer)
            raise ArgumentError, 'committer is mandatory' if committer.nil?
            @committer = committer
          end

          def time_committed=(time_committed)
            if time_committed.nil?
              raise ArgumentError, 'time_committed is mandatory'
            end
            @time_committed = time_committed
          end
             
          def change_type=(change_type)
            raise ArgumentError, 'change_type is mandatory' if change_type.nil?
            @change_type = change_type
          end
        end

        class RevisionHistory
          attr_reader :items

          def initialize(args = { })
            self.items = args[:items]
          end

          def items=(items)
            if items.nil? or items.empty?
              raise ArgumentError, 'item(s) is/are mandatory'
            end
            @items  = items
          end

          def most_recent_version
            return @items.last.version_id.value
          end

          def most_recent_version_time_committed
            return @items.last.audits.first.time_committed.value
          end
        end # of RevisionHistory

        class RevisionHistoryItem
          attr_reader :version_id, :audits

          def initialize(args = { })
            self.version_id = args[:version_id]
            self.audits = args[:audits]
          end

          def audits=(audits)
            if audits.nil? or audits.empty?
              raise ArgumentError, 'audits is mandatory'
            end
            @audits = audits
          end

          def version_id=(version_id)
            raise ArgumentError, 'version_id is mandatory' if version_id.nil?
            @version_id = version_id
          end
        end # of RevisionHistory_Item

        class PartyProxy
          attr_accessor :external_ref

          def initialize(args = { })
            self.external_ref = args[:external_ref]
          end
        end

        class PartySelf < PartyProxy

        end

        class PartyIdentified < PartyProxy
          attr_reader :name, :identifier

          def initialize(args = { })
            if args[:external_ref].nil? && args[:name].nil? &&
                args[:identifier].nil?
              raise ArgumentError, 'cannot identified'
            end
            self.name = args[:name]
            self.identifier = args[:identifier]
            super(args)
          end

          def name=(name)
            if name.nil? && @external_ref.nil? && @identifier.nil?
              raise ArgumentError, 'cannot identified'
            end
            raise ArgumentError, 'invaild name' unless name.nil? || !name.empty?
            @name = name
          end

          def identifier=(identifier)
            if @name.nil? && @external_ref.nil? && identifier.nil?
              raise ArgumentError, 'cannot identified'
            end
            if !identifier.nil? && identifier.empty?
              raise ArgumentError, 'invaild identifier'
            end
            @identifier = identifier
          end

          def external_ref=(external_ref)
            if @name.nil? && @identifier.nil? && external_ref.nil?
              raise ArgumentError, 'invalid external_ref'
            end
            @external_ref = external_ref
          end
        end

        class PartyRelated < PartyIdentified
          attr_reader :relationship
          def initialize(args = { })
            super(args)
            self.relationship = args[:relationship]
          end

          def relationship=(relationship)
            if relationship.nil?
              raise ArgumentError, 'relationship must not be nil'
            end
            @relationship = relationship
          end
        end

        class Participation
          attr_reader :performer, :function, :mode
          attr_accessor :time

          def initialize(args ={ })
            self.performer = args[:performer]
            self.function = args[:function]
            self.mode = args[:mode]
            self.time = args[:time]
          end

          def performer=(performer)
            raise ArgumentError, 'performer is mandatory' if performer.nil?
            @performer = performer
          end

          def function=(function)
            raise ArgumentError, 'function is mandatory' if function.nil?
            @function = function
          end

          def mode=(mode)
            raise ArgumentError, 'mode is mandatory' if mode.nil?
            @mode = mode
          end
        end

        class Attestation < AuditDetails
          attr_reader :reason
          attr_accessor :proof, :attested_view, :is_pending, :items

          def initialize(args = { })
            super(args)
            self.reason = args[:reason]
            self.proof = args[:proof]
            self.items = args[:items]
            self.attested_view = args[:attested_view]
            self.is_pending = args[:is_pending]
          end

          def reason=(reason)
            raise ArgumentError, 'reason is mandatory' if reason.nil?
            @reason = reason
          end

          def items=(items)
            if !items.nil? && items.empty?
              raise ArgumentError, 'items should not be empty'
            end
            @items = items
          end
          
          def is_pending?
            return is_pending
          end
        end
      end # of Generic
    end # of Common
  end # of RM
end # of OpenEHR
