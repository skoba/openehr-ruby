# rm::ehr
# ehr module
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109004889781_854011_47Report.html
# refs #44
require_relative 'common/change_control'

module OpenEHR
  module RM
    module EHR
      class EHR
        attr_reader :system_id, :ehr_id, :time_created, :contributions,
                    :ehr_access, :ehr_status, :compositions, :directory,
                    :folders

        def initialize(args = { })
          self.system_id = args[:system_id]
          self.ehr_id = args[:ehr_id]
          self.time_created = args[:time_created]
          self.contributions = args[:contributions]
          self.ehr_access = args[:ehr_access]
          self.ehr_status = args[:ehr_status]
          self.compositions = args[:compositions]
          self.directory = args[:directory]
          self.folders = args[:folders]
        end

        def system_id=(system_id)
          if system_id.nil?
            raise ArgumentError, 'system_id is mandatory'
          end
          @system_id = system_id
        end

        def ehr_id=(ehr_id)
          if ehr_id.nil?
            raise ArgumentError, 'ehr_id is mandatory'
          end
          @ehr_id = ehr_id
        end

        def time_created=(time_created)
          if time_created.nil?
            raise ArgumentError, 'time_created is mandatory'
          end
          @time_created = time_created
        end

        # contributions is optional (0..1) since RM 1.1.0 (was mandatory
        # pre-1.1.0).
        def contributions=(contributions)
          unless contributions.nil?
            contributions.each do |contrib|
              unless contrib.type == 'CONTRIBUTION'
                raise ArgumentError, 'contribution type should be CONTRIBUTION'
              end
            end
          end
          @contributions = contributions
        end

        def ehr_access=(ehr_access)
          if ehr_access.nil? || ehr_access.type != 'VERSIONED_EHR_ACCESS'
            raise ArgumentError, 'ehr_access is invalid'
          end
          @ehr_access = ehr_access
        end

        def ehr_status=(ehr_status)
          if ehr_status.nil? || ehr_status.type != 'VERSIONED_EHR_STATUS'
            raise ArgumentError, 'ehr_status is invalid'
          end
          @ehr_status = ehr_status
        end

        # compositions is optional (0..1) since RM 1.1.0 (was mandatory
        # pre-1.1.0).
        def compositions=(compositions)
          unless compositions.nil?
            compositions.each do |compo|
              unless compo.type == 'VERSIONED_COMPOSITION'
                raise ArgumentError, 'composition type should be VERSIONED_COMPOSITION'
              end
            end
          end
          @compositions = compositions
        end

        def directory=(directory)
          if !directory.nil? && directory.type != 'VERSIONED_FOLDER'
            raise ArgumentError, 'invalid directory'
          end
          @directory = directory
        end

        # RM 1.1.0 (SPECRM-55): additional Folder hierarchies for this
        # EHR. When set, directory is kept pointing at folders.item(1)
        # (the Directory_in_folders invariant), for backward
        # compatibility with pre-1.1.0 systems that only had directory.
        def folders=(folders)
          unless folders.nil?
            folders.each do |f|
              if f.type != 'VERSIONED_FOLDER'
                raise ArgumentError, 'folder type should be VERSIONED_FOLDER'
              end
            end
            @directory = folders.first
          end
          @folders = folders
        end
      end

      class VersionedEHRAccess < OpenEHR::RM::Common::ChangeControl::VersionedObject

      end

      class EHRAccess < OpenEHR::RM::Common::Archetyped::Locatable
        attr_accessor :settings
        attr_reader :scheme

        def initialize(args = { })
          super(args)
          self.settings = args[:settings]
          self.scheme = args[:scheme]
        end

        def scheme=(scheme)
          if scheme.nil? || scheme.empty?
            raise ArgumentError, 'scheme is mandatory'
          end
          @scheme = scheme
        end
      end

      class VersionedEHRStatus < OpenEHR::RM::Common::ChangeControl::VersionedObject

      end

      class EHRStatus < OpenEHR::RM::Common::Archetyped::Locatable
        attr_reader :subject
        attr_accessor :is_modifiable, :is_queryable, :other_details
        path_attribute :other_details

        def initialize(args = { })
          super(args)
          self.subject = args[:subject]
          self.is_queryable = args[:is_queryable]
          self.is_modifiable = args[:is_modifiable]
          self.other_details = args[:other_details]
        end

        def subject=(subject)
          raise ArgumentError, 'subject is mandatory' if subject.nil?
          @subject = subject
        end

        def is_queryable?
          return @is_queryable
        end

        def is_modifiable?
          return @is_modifiable
        end

        def parent=(parent)
          unless parent.nil?
            raise ArgumentError, 'parent should be nil'
          end
          @parent = parent
        end
      end

      class VersionedComposition < OpenEHR::RM::Common::ChangeControl::VersionedObject
        def is_persistent?
          return @all_versions.first.data.is_persistent?
        end
      end
    end # of EHR
  end # of RM
end # of OpenEHR
