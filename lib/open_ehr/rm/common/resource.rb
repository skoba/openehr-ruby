require 'set'
module OpenEHR
  module RM
    module Common
      module Resource
        class AuthoredResource
          attr_reader  :original_language, :translations
          attr_accessor :description, :revision_history

          def initialize(args = { })
            self.original_language = args[:original_language]
            self.translations = args[:translations]
            self.revision_history = args[:revision_history]
            self.description = args[:description]
          end

          def original_language=(original_language)
            if original_language.nil?
              raise ArgumentError, 'original language is mandatory'
            end
            @original_language = original_language
          end

          def translations=(translations)
            if !translations.nil? && translations.empty?
              raise ArgumentError, 'translation is empty'
            end
            @translations = translations
          end

          def current_revision
            @revision_history.most_recent_version
          end

          def languages_available
            return Set.new(@translations.keys) << original_language.code_string
          end

          def is_controlled?
            return !@revision_history.nil?
          end
        end

        class TranslationDetails
          attr_reader :language, :author
          attr_accessor :accreditation, :other_details

          def initialize(args = {})
            self.language = args[:language]
            self.author = args[:author]
            self.accreditation = args[:accreditation]
            self.other_details = args[:other_details]
          end

          def language=(language)
            raise ArgumentError, 'language is mandatory' if language.nil?
            @language = language
          end

          def author=(author)
            raise ArgumentError, 'author is mandatory' if author.nil?
            @author = author
          end
        end

        class ResourceDescription
          attr_reader :original_author, :lifecycle_state, :details
          attr_accessor :other_contributors, :resource_package_uri,
                        :other_details, :parent_resource

          def initialize(args = {})
            self.original_author = args[:original_author]
            self.lifecycle_state = args[:lifecycle_state]
            self.details = args[:details]
            self.other_contributors = args[:other_contributors]
            self.resource_package_uri = args[:resource_package_uri]
            self.other_details = args[:other_details]
            self.parent_resource = args[:parent_resource]
          end

          def original_author=(original_author)
            if original_author.nil? || original_author.empty?
              raise ArgumentError, 'original_author is mandatory'
            end
            @original_author = original_author
          end

          def lifecycle_state=(lifecycle_state)
            if lifecycle_state.nil? || lifecycle_state.empty?
              raise ArgumentError, 'lifecycle_state is malformatted'
            end
            @lifecycle_state = lifecycle_state
          end

          def details=(details)
            if details.nil? || details.empty?
              raise ArgumentError, 'nil or empty details'
            end
            @details = details
          end
        end

        class ResourceDescriptionItem
          attr_reader :language, :purpose, :use, :misuse, :copyright
          attr_accessor :keywords, :original_resource_uri, :other_details

          def initialize(args = { })
            self.language = args[:language]
            self.purpose = args[:purpose]
            self.keywords = args[:keywords]
            self.use = args[:use]
            self.misuse = args[:misuse]
            self.copyright = args[:copyright]
            self.original_resource_uri = args[:original_resource_uri]
            self.other_details = args[:other_details]
          end

          def language=(language)
            raise ArgumentError, 'language is mandatory' if language.nil?
            @language = language
          end

          def purpose=(purpose)
            if purpose.nil? || purpose.empty?
              raise ArgumentError, 'purpose is mandatory'
            end
            @purpose = purpose
          end

          def use=(use)
            if !use.nil? && use.empty?
              raise ArgumentError, 'use is invalid'
            end
            @use = use
          end

          def misuse=(misuse)
            if !misuse.nil? && misuse.empty?
              raise ArgumentError, 'misuse is invalid'
            end
            @misuse = misuse
          end

          def copyright=(copyright)
            if !copyright.nil? && copyright.empty?
              raise ArgumentError, 'copyright is invalid'
            end
            @copyright = copyright
          end
        end
      end # end of Resouce
    end # end of module Common
  end # end of module RM
end # end of module OpenEHR
