# This module implemented from this UML
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109067605961_209522_3179Report.html
# Ticket refs #48
include OpenEHR::RM::DataTypes::Basic

module OpenEHR
  module RM
    module DataTypes
      module Text
        class TermMapping
          attr_reader :match, :purpose, :target

          def initialize(args ={})
            self.match = args[:match]
            self.purpose = args[:purpose]
            self.target = args[:target]
          end

          def match=(match)
            unless TermMapping.is_valid_mach_code? match
              raise ArgumentError, 'invalid match character'
            end
            @match = match
          end

          def purpose=(purpose)
#            if !purpose.nil? and !purpose.instance_of?(DvCodedText)
#              raise ArgumentError, "purpose is not valid"
#            end
            # should be settled after terminology service implemented
            @purpose = purpose
          end

          def target=(target)
            raise ArgumentError, "target must not be nil" if target.nil?
            @target = target
          end

          def broader?
            match == '>'
          end

          def equivalent?
            match == '='
          end

          def narrower?
            match == '<'
          end

          def unknown?
            match == '?'
          end

          def TermMapping.is_valid_mach_code?(c)
            c == '>' or c == '=' or c == '<' or c == '?'
          end
        end

        class CodePhrase
          attr_reader :terminology_id, :code_string

          def initialize(args = {})
            self.code_string = args[:code_string]
            self.terminology_id = args[:terminology_id]
          end

          def terminology_id=(terminology_id)
            if terminology_id.nil?
              raise ArgumentError, "terminology_id should not be nil"
            end
            @terminology_id = terminology_id
          end

          def code_string=(code_string)
            if code_string.nil? or code_string.empty?
              raise ArgumentError, "code_string should not be empty"
            end
            @code_string = code_string
          end 
        end # of CodePhrase

        class DvText < OpenEHR::RM::DataTypes::Basic::DataValue
          attr_reader :formatting, :hyperlink, :mappings,
                      :language, :encoding
          attr_accessor :hyperlink

          def initialize(args = {})
            super(args)
            self.formatting = args[:formatting]
            self.encoding = args[:encoding]
            self.mappings = args[:mappings]
            self.language = args[:language]
            self.hyperlink = args[:hyperlink]
          end

          def value=(value)
            if value.nil? or value.empty? or 
                value.include? CR or value.include? LF
              raise ArgumentError, "value is not valid"
              # CR and LF are defined in Basic_Definition inherited DataValue.
            end
            @value = value
          end

          def formatting=(formatting)
            if !formatting.nil? and formatting.empty?
              raise ArgumentError, "formatting is not valid"
            end
            @formatting = formatting
          end

          def encoding=(encoding)
            if !encoding.nil? and encoding.code_string.empty?
              raise ArgumentError, "encoding is not valid"
            end
            @encoding = encoding
          end

          def mappings=(mappings)
            if !mappings.nil? && mappings.empty?
              raise ArgumentError, 'mappings should not be empty'
            end
            @mappings = mappings
          end

          def language=(language)
            if !language.nil? and language.code_string.empty?
              raise ArgumentError, "langage is not valid"
            end
            @language = language
          end
        end

        class DvCodedText < DvText
          attr_reader :defining_code

          def initialize(args = {})
            super(args)
            self.defining_code = args[:defining_code]
          end

          def defining_code=(defining_code)
            if defining_code.nil?
              raise ArgumentError, 'defiining code is mandatory'
            end
            @defining_code = defining_code
          end
        end

        class DvParagraph < OpenEHR::RM::DataTypes::Basic::DataValue
          attr_reader :items

          def initialize(args ={})
            self.items = args[:items]
          end

          def items=(items)
            if items.nil? or items.empty?
              raise ArgumentError, "Items are not valid"
            end
            @items = items
          end
        end

      end # of Text
    end # of DataTypes
  end # of RM
end # of OpenEHR
