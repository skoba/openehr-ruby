# This module is based on the UML,
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109326589721_134411_997Report.html
# Ticket refs #64
require_relative 'generic'

module OpenEHR
  module RM
    module Common
      module ChangeControl
        class Contribution
          attr_reader :uid, :versions, :audit

          def initialize(args = { })
            self.uid = args[:uid]
            self.versions = args[:versions]
            self.audit = args[:audit]
          end

          def uid=(uid)
            if uid.nil?
              raise ArgumentError, "uid should not be nil."
            end
            @uid = uid
          end

          def versions=(versions)
            unless versions.nil?
              if versions.empty?
                raise ArgumentError, 'versions shoud not be nil or empty.'
              end
            end
            @versions = versions
          end

          def audit=(audit)
            if audit.nil?
              raise ArgumentError, 'audit should not be nil.'
            end
            if audit.description.nil?
              raise ArgumentError, 'audit.description should not be nil.'
            end
            @audit = audit
          end
        end

        class Version
          attr_reader :uid, :preceding_version_uid, :lifecycle_state,
                      :commit_audit, :contribution
          attr_accessor :data, :signature

          def initialize(args = { })
            self.uid = args[:uid]
            self.preceding_version_uid = args[:preceding_version_uid]
            self.data = args[:data]
            self.lifcycle_state = args[:lifecycle_state]
            self.commit_audit = args[:commit_audit]
            self.contribution = args[:contribution]
            self.signature = args[:signature]
          end

          def uid=(uid)
            raise ArgumentError, "uid should not be nil" if uid.nil?
            @uid = uid
          end

          def preceding_version_uid=(preceding_version_uid)
            if (!preceding_version_uid.nil?) ==  @uid.version_tree_id.is_first?
              raise ArgumentError, 'preceding version is invalid'
            end
            @preceding_version_uid = preceding_version_uid
          end

# remove hard coding of lifecycle
          def lifcycle_state=(lifecycle_state)
            if lifecycle_state.nil? ||
                !%w[532 553 523].include?(
                              lifecycle_state.defining_code.code_string)
              raise ArgumentError, 'invalid lifecycle_state'
            end
            @lifecycle_state = lifecycle_state
          end

          def commit_audit=(commit_audit)
            if commit_audit.nil?
              raise ArgumentError,'commit_audit is mandatory'
            end
            @commit_audit = commit_audit
          end

          def contribution=(contribution)
            if contribution.nil? or contribution.type.empty?
              raise ArgumentError, "contribution is invalid"
            end
            if contribution.type == 'CONTRIBUTION'
              @contribution = contribution
            else
              raise ArgumentError, 'contribution is invalid'
            end
          end

          def owner_id
            return HierObjectID.new(:value => @uid.value)
          end

          def is_branch?
            return @uid.is_branch?
          end

          def canonical_form
            raise NotImplementedError, 'canonical form is not determined'
          end
        end

        class ImportedVersion < Version
          attr_reader :item

          def initialize(args = { })
            self.item = args[:item]
            super(:uid => @item.uid,
                  :preceding_version_uid => @item.preceding_version_uid,
                  :data => @item.data, :commit_audit=> args[:commit_audit],
                  :commit_audit => args[:commit_audit],
                  :contribution => args[:contribution],
                  :lifecycle_state => @item.lifecycle_state,
                  :signature => args[:signature])                  
          end

          def item=(item)
            raise ArgumentError, 'item is mandatory' if item.nil?
            @item = item
          end
        end

        class OriginalVersion < Version
          attr_reader :attestations, :other_input_version_uids

          def initialize(args = { })
            super(args)
            self.attestations = args[:attestations]
            self.other_input_version_uids = args[:other_input_version_uids]
          end

          def attestations=(attestations)
            if !attestations.nil? && attestations.empty?
              raise ArgumentError, 'invalid attestations'
            end
            @attestations = attestations
          end

          def other_input_version_uids=(other_input_version_uids)
            if !other_input_version_uids.nil? && other_input_version_uids.empty?
              raise ArgumentError, 'invaild other_input_version_uids'
            end
            @other_input_version_uids = other_input_version_uids
          end

          def is_merged?
            return !other_input_version_uids.nil?
          end
        end

        class VersionedObject
          attr_reader :uid, :owner_id, :time_created, :all_versions

          def initialize(args = { })
            self.uid = args[:uid]
            self.owner_id = args[:owner_id]
            self.time_created = args[:time_created]
            self.all_versions = args[:all_versions]
          end

          def uid=(uid)
            raise ArgumentError, 'uid is mandatory' if uid.nil?
            @uid = uid
          end

          def owner_id=(owner_id)
            raise ArgumentError, 'owner_id is mandatory' if owner_id.nil?
            @owner_id = owner_id
          end

          def time_created=(time_created)
            if time_created.nil?
              raise ArgumentError, 'time_created is mandatory'
            end
            @time_created = time_created
          end

          def all_versions=(all_versions)
            if all_versions.nil? || all_versions.size < 0
              raise ArgumentError, 'version count invalid'
            end
            @all_versions = all_versions
          end

          def all_version_ids
            ids = []
            @all_versions.each{|id| ids << id.uid}
            return ids
          end

          def version_count
            return all_versions.size
          end

          def has_version_id?(a_ver_id)
            raise ArgumentError, 'argument is mandatory' if a_ver_id.nil?
            return self.all_version_ids.include?(a_ver_id)
          end

          def is_original_version?(a_ver_id)
            if a_ver_id.nil? || !self.has_version_id?(a_ver_id)
              raise ArgumentError, 'invalid a_ver_id'
            end
            return @all_versions[self.all_version_ids.index(a_ver_id)].instance_of? OriginalVersion
          end

          def has_version_at_time?(a_time)
            raise ArgumentError, 'argument mandatory' if a_time.nil?
            @all_versions.each do |ver|
              if ver.commit_audit.time_committed == a_time
                return true
              end
            end
            return false
          end

          def version_with_id(a_ver_id)
            if a_ver_id.nil? || !self.has_version_id?(a_ver_id)
              raise ArgumentError, 'argument invalid'
            end
            return @all_versions[self.all_version_ids.index(a_ver_id)]
          end

          def version_at_time(a_time)
            if a_time.nil? || !self.has_version_at_time?(a_time)
              raise ArgumentError, 'argument invalid'
            end
            @all_versions.each do |ver|
              if ver.commit_audit.time_committed == a_time
                return ver
              end
            end
          end

          def latest_version
            time_sorted_version = @all_versions.sort do |a,b|
              a.commit_audit.time_committed <=> b.commit_audit.time_committed
            end
            return time_sorted_version.last
          end

          def latest_trunk_version
            trunk_versions = [ ]
            @all_versions.each do |ver|
              if ver.uid.version_tree_id.trunk_version == '1'
                trunk_versions << ver
              end
            end
            sorted_trunk_version = trunk_versions.sort do |a,b|
              a.commit_audit.time_committed <=> b.commit_audit.time_committed
            end
            return sorted_trunk_version.last
          end

          def trunk_lifecycle_state
            return self.latest_trunk_version.lifecycle_state
          end

          def revision_history
            revision_history_items = [ ]
            @all_versions.each do |ver|
              audits = [ ]
              if ver.instance_of? OriginalVersion
                audits << ver.attestations
              end
              audits << ver.commit_audit
              revision_history_items << OpenEHR::RM::Common::Generic::RevisionHistoryItem.new(
                                          :audits => audits,
                                          :version_id => ver.uid)
            end
            return OpenEHR::RM::Common::Generic::RevisionHistory.new(:items => revision_history_items)
          end

          def commit_original_version(args={ })
            if has_version_id?(args[:preceding_version_uid]) or self.version_count == 0
              @all_versions << OriginalVersion.new(:uid => args[:uid],
                                                   :preceding_version_uid => args[:preceding_version_uid],
                                                   :contribution => args[:contribution],
                                                   :commit_audit => args[:commit_audit],
                                                   :lifecycle_state => args[:lifecycle_state],
                                                   :data => args[:data],
                                                   :attestations => args[:attestations],
                                                   :signature => args[:signature])
            else
              raise ArgumentError, 'invalid preceding uid'
            end
          end
            
          def commit_original_merged_version(args = { })
            @all_versions << OriginalVersion.new(:uid => args[:uid],
                                                  :contribution => args[:contribution],
                                              :preceding_version_uid => args[:preceding_version_uid],
                                              :commit_audit => args[:commit_audit],
                                              :lifecycle_state => args[:lifecycle_state],
                                              :data => args[:data],
                                              :attestations => args[:attestations],
                                              :other_input_version_uids => args[:other_input_version_uids],
                                              :signature => args[:signature])
          end

          def commit_imported_version(args = { })
            @all_versions << ImportedVersion.new(:item => args[:item],
                                                 :contribution => args[:contribution],
                                                 :commit_audit => args[:commit_audit])
          end

          def commit_attestation(args = { })
            if args[:attestation].nil?
              raise ArgumentError, 'attestation is mandatory'
            end
            if self.has_version_id?(args[:uid]) && self.is_original_version?(args[:uid])
              self.version_with_id(args[:uid]).attestations << args[:attestation]
              self.version_with_id(args[:uid]).signature = args[:signature]
            else
              raise ArgumentError, 'uid invalid'
            end
          end
        end
      end # of ChangeControl
    end # of Common
  end # of RM
end # of OpenEHR
