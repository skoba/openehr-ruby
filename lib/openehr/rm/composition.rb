# rm::composition
# composition module
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109005072243_448526_217Report.html
# refs #79
include OpenEHR::RM::Common::Archetyped
module OpenEHR
  module RM
    module Composition
      class Composition < Locatable
        attr_reader :language, :category, :territory, :composer
        attr_accessor :content, :context

        def initialize(args = { })
          super(args)
          self.language = args[:language]
          self.category = args[:category]
          self.territory = args[:territory]
          self.composer = args[:composer]
          self.content = args[:content]
          self.context = args[:context]
        end

        def language=(language)
          if language.nil?
            raise ArgumentError, 'language is mandatory'
          end
          @language = language
        end

        def category=(category)
          if category.nil?
            raise ArgumentError, 'category is mandatory'
          end
          @category = category
        end

        def territory=(territory)
          if territory.nil?
            raise ArgumentError, 'territory is mandatory'
          end
          @territory = territory
        end

        def composer=(composer)
          if composer.nil?
            raise ArgumentError, 'composer is mandatory'
          end
          @composer = composer
        end

        def is_persistent?
          return category.value == 'persistent'
        end
      end

      class EventContext < Pathable
        attr_reader :start_time, :setting, :participations, :location
        attr_accessor :end_time, :other_context

        def initialize(args = { })
          super(args)
          self.start_time = args[:start_time]
          self.setting = args[:setting]
          self.end_time = args[:end_time]
          self.participations = args[:participations]
          self.location = args[:location]
          self.other_context = args[:other_context]
        end

        def start_time=(start_time)
          if start_time.nil?
            raise ArgumentError, 'start_time is mandatory'
          end
          @start_time = start_time
        end

        def setting=(setting)
          if setting.nil?
            raise ArgumentError, 'setting is mandatory'
          end
          @setting = setting
        end

        def participations=(participations)
          if !participations.nil? and participations.empty?
            raise ArgumentError, 'participations should not be empty'
          end
          @participations = participations
        end

        def location=(location)
          if !location.nil? and location.empty?
            raise ArgumentError, 'location should not be empty'
          end
          @location = location
        end
      end

      require 'composition/content'

    end # end of Composition
  end # end of RM
end # end of OpenEHR
