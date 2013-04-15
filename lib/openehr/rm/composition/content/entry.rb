# rm::composition::content::entry
# entry module
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109264528523_312165_346Report.html
# refs #56
require 'locale/info'

module OpenEHR
  module RM
    module Composition
      module Content
        module Entry
          class Entry < ::OpenEHR::RM::Composition::Content::ContentItem
            attr_reader :language, :encoding, :subject
            attr_accessor :provider, :other_participations, :workflow_id

            def initialize(args = { })
              super(args)
              self.language = args[:language]
              self.encoding = args[:encoding]
              self.subject = args[:subject]
              self.provider = args[:provider]
              self.other_participations = args[:other_participations]
              self.workflow_id = args[:workflow_id]
            end

            def language=(language)
              raise ArgumentError, 'language is mandatory' if language.nil?
              unless Locale::Info.language_code? language.code_string
                raise ArgumentError, 'language code is invalid'
              end
              @language = language
            end

            def encoding=(encoding)
              if encoding.nil?
                raise ArgumentError, 'encoding is mandatory'
              end
              Encoding.find(encoding.code_string)
              @encoding = encoding
            end

            def subject=(subject)
              raise ArgumentError, 'subject is mandatory' if subject.nil?
              @subject = subject
            end

            def subject_is_self?
              return @subject.instance_of? PartySelf
            end
          end

          class AdminEntry < Entry
            attr_reader :data

            def initialize(args = { })
              super(args)
              self.data = args[:data]
            end

            def data=(data)
              raise ArgumentError, 'data are mandatory' if data.nil?
              @data = data
            end
          end
          class CareEntry < Entry
            attr_accessor :protocol, :guideline_id

            def initialize(args = { })
              super(args)
              self.protocol = args[:protocol]
              self.guideline_id = args[:guideline_id]
            end
          end

          class Observation < CareEntry
            attr_reader :data
            attr_accessor :state

            def initialize(args = { })
              super(args)
              self.data = args[:data]
              self.state = args[:state]
            end

            def data=(data)
              raise ArgumentError, 'data are mandatory' if data.nil?
              @data = data
            end
          end

          class Evaluation < CareEntry
            attr_reader :data

            def initialize(args = { })
              super(args)
              self.data = args[:data]
            end

            def data=(data)
              raise ArgumentError, 'data are mandatory' if data.nil?
              @data = data
            end
          end

          class Instruction < CareEntry
            attr_reader :narrative, :activities
            attr_accessor :expiry_time, :wf_definition

            def initialize(args = { })
              super(args)
              self.narrative = args[:narrative]
              self.activities = args[:activities]
              self.expiry_time = args[:expiry_time]
              self.wf_definition = args[:wf_definition]
            end

            def narrative=(narrative)
              if narrative.nil?
                raise ArgumentError, 'narrative is mandatory'
              end
              @narrative = narrative
            end

            def activities=(activities)
              if !activities.nil? && activities.empty?
                raise ArgumentError, 'activities should not be empty'
              end
              @activities = activities
            end
          end

          class Activity < OpenEHR::RM::Common::Archetyped::Locatable
            attr_reader :description, :timing, :action_archetype_id

            def initialize(args = { })
              super(args)
              self.description = args[:description]
              self.timing = args[:timing]
              self.action_archetype_id = args[:action_archetype_id]
            end

            def description=(description)
              if description.nil?
                raise ArgumentError, 'description is mandatory'
              end
              @description = description
            end

            def timing=(timing)
              if timing.nil?
                raise ArgumentError, 'timing is mandatory'
              end
              @timing = timing
            end

            def action_archetype_id=(action_archetype_id)
              if action_archetype_id.nil? || action_archetype_id.empty?
                raise ArgumentError, 'action_archetype_id is mandatory'
              end
              @action_archetype_id = action_archetype_id
            end
          end

          class Action < CareEntry
            attr_reader :time, :description, :ism_transition
            attr_accessor :instruction_details
            
            def initialize(args = { })
              super(args)
              self.description = args[:description]
              self.time = args[:time]
              self.ism_transition = args[:ism_transition]
              self.instruction_details = args[:instruction_details]
            end

            def time=(time)
              if time.nil?
                raise ArgumentError, 'time is mandatory'
              end
              @time = time
            end

            def description=(description)
              if description.nil?
                raise ArgumentError, 'description is mandatory'
              end
              @description = description
            end

            def ism_transition=(ism_transition)
              if ism_transition.nil?
                raise ArgumentError
              end
              @ism_transition = ism_transition
            end
          end

          class InstructionDetails < OpenEHR::RM::Common::Archetyped::Pathable
            attr_reader :instruction_id, :activity_id
            attr_accessor :wf_details

            def initialize(args = { })
              super(args)
              self.instruction_id = args[:instruction_id]
              self.activity_id = args[:activity_id]
              self.wf_details = args[:wf_details]
            end

            def instruction_id=(instruction_id)
              if instruction_id.nil?
                raise ArgumentError, 'instruction_id is mandatory'
              end
              @instruction_id = instruction_id
            end

            def activity_id=(activity_id)
              if activity_id.nil? || activity_id.empty?
                raise ArgumentError, 'activity_id is mandatory'
              end
              @activity_id = activity_id
            end
          end

          class IsmTransition < OpenEHR::RM::Common::Archetyped::Pathable
            attr_reader :current_state, :transition
            attr_accessor :careflow_step

            def initialize(args = { })
              super(args)
              self.current_state = args[:current_state]
              self.transition = args[:transition]
              self.careflow_step = args[:careflow_step]
            end

            def current_state=(current_state)
              if current_state.nil?
                raise ArgumentError, 'current_state is mandatory'
              end
              @current_state = current_state
            end

            def transition=(transition)
              if transition.nil?
                raise ArgumentError, 'transition is mandatory'
              end
              @transition = transition
            end
          end
        end # of Entry
      end # of Content
    end # of Composition
  end # of RM
end # of OpenEHR
