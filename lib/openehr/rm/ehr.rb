# rm::ehr
# ehr module
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109004889781_854011_47Report.html
# refs #44
module OpenEHR
  module RM
    module EHR
      class EHR
        attr_reader :system_id, :ehr_id, :time_created, :contributions,
                    :ehr_access, :ehr_status, :compositions, :directory

        def initialize(args = { })
          self.system_id = args[:system_id]
          self.ehr_id = args[:ehr_id]
          self.time_created = args[:time_created]
          self.contributions = args[:contributions]
          self.ehr_access = args[:ehr_access]
          self.ehr_status = args[:ehr_status]
          self.compositions = args[:compositions]
          self.directory = args[:directory]
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

        def contributions=(contributions)
          unless contributions.nil?
            contributions.each do |contrib|
              unless contrib.type == 'CONTRIBUTION'
                raise ArgumentError, 'contribution type should be CONTRIBUTION'
              end
            end
            @contributions = contributions
          else
            raise ArgumentError, 'contributions are mandatory'
          end
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

        def compositions=(compositions)
          unless compositions.nil?
            compositions.each do |compo|
              unless compo.type == 'VERSIONED_COMPOSITION'
                raise ArgumentError, 'composition type should be VERSIONED_COMPOSITION'
              end
            end
            @compositions = compositions
          else
            raise ArgumentError, 'compositions are mandatory'
          end
        end

        def directory=(directory)
          if !directory.nil? && directory.type != 'VERSIONED_FOLDER'
            raise ArgumentError, 'invalid directory'
          end
          @directory = directory
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
