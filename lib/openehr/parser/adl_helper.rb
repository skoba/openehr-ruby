require 'openehr/rm/data_types/text'
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::Common::Resource

module OpenEHR
  module Parser
    module ADLGrammar
      class Base < Treetop::Runtime::SyntaxNode

      end

      class ArchLanguage < Base
        def value
          return Language.new(lang.value)
        end
      end

      class Language
        include OpenEHR::RM::DataTypes::Text
        attr_reader :original_language, :translations
        
        def initialize(value)
          self.original_language = value['original_language']
          self.translations = value['translations']
        end
        
        def original_language=(original_language)
          @original_language = original_language
        end
        
        def translations=(translations)
          if translations.nil?
            @translations = nil
          else
            tr = translations.inject({ }) do |trans, lang|
              code, details  = lang
              td = TranslationDetails.new(
                     :language => details['language'],
                     :author => details['author'],
                     :accreditation => details['accreditation'],
                     :other_details => details['other_details'])
              trans.update Hash[code, td]
            end
            @translations = tr
          end
        end
        
        protected
        def code2lang(code)
          ti, la = code.split '::'
          ti = TerminologyID.new(:value => ti)
          CodePhrase.new(:code_string => la, :terminology_id => ti)
        end
      end
    end

    class ArchetypeNode
      attr_reader :parent
      attr_accessor :path, :id
      
      def initialize(parent = nil)
        @parent = parent
        @path = '/' if parent.nil?
      end
      
      def root?
        return parent.nil?
      end
    end

    class CDvQuantityItems < Treetop::Runtime::SyntaxNode
      def value(node)
        property = prop.value unless prop.empty?
        list = ql.value(node) unless ql.empty?
        av = aqv.value unless aqv.empty?
        OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvQuantity.new(
             :path => node.path, :rm_type_name => 'DvQuantity',
             :occurrences => OpenEHR::AssumedLibraryTypes::Interval.new(
                             :upper => 1, :lower => 1),
             :property => property, :list => list, :assumed_value => av)
      end
    end
    
    class AssumedValueItems < Treetop::Runtime::SyntaxNode
      def value
        magnitude, precision = nil
          magnitude = mag.val.value unless mag.empty?
          precision = prec.val.value unless prec.empty?
          OpenEHR::RM::DataTypes::Quantity::DvQuantity.new(
            :units => units.value,
            :magnitude => magnitude,
            :precision => precision)
      end
    end
  end # of Parser
end # of openEHR
