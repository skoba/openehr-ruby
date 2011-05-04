# OpenEHR::RM::Data_Types::Encapsulated 
# http://www.openehr.org/svn/specification/TAGS/Release-1.0.2/publishing/architecture/computable/UML/uml_start_view.html
# refs #51
require 'rubygems'
require 'locale/info'

module OpenEHR
  module RM
    module DataTypes
      module Encapsulated
        class DvEncapsulated  < OpenEHR::RM::DataTypes::Basic::DataValue
          attr_reader :language, :charset

          def initialize(args = {})
            super(args)
            self.charset = args[:charset]
            self.language = args[:language]
          end

          def size
            @value.size
          end

          def language=(language)
            if !language.nil? &&
                !Locale::Info.language_code?(language.code_string)
              raise ArgumentError, 'invalid language code'
            end
            @language = language
          end

          def charset=(charset)
            if !charset.nil? && !charset_valid?(charset.code_string)
              raise ArgumentError, 'invalid charset'
            end
            @charset = charset
          end

          private

          def charset_valid?(charset)
            result = false
            open('lib/open_ehr/rm/data_types/charset.lst') do |file|
              while line = file.gets
                if charset == line.chomp
                  result = true
                  break
                end
              end
            end
            return result
          end
        end

# media type http://www.iana.org/assignments/media-types/text/
        class DvMultimedia < DvEncapsulated
          attr_reader :media_type
          attr_accessor :uri, :data, :compression_algorithm,
          :integrity_check, :integrity_check_algorithm, :alternate_text

          def initialize(args = {})
            super(args)
            self.media_type = args[:media_type]
            self.uri = args[:uri]
            self.data = args[:data]
            self.compression_algorithm = args[:compression_algorithm]
            self.integrity_check = args[:integrity_check]
            self.integrity_check_algorithm = args[:integrity_check_algorithm]
            self.alternate_text = args[:alternate_text]
          end

          def media_type=(media_type)
            if media_type.code_string.nil?
              raise ArgumentError, 'media_type should not be nil'
            end
            @media_type = media_type
          end
        end

        class DvParsable < DvEncapsulated
          attr_reader :formalism

          def initialize(args = {})
            super(args)
            self.formalism = args[:formalism]
          end

          def formalism=(formalism)
            if formalism.nil? || formalism.empty?
              raise ArgumentError, 'formalism is mandatory'
            end
            @formalism = formalism
          end
        end
      end # of Encapsulated
    end # of DataTypes
  end # of RM
end # of OpenEHR
