require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::Ontology
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataTypes::Text
include OpenEHR::AssumedLibraryTypes

def sample_archetype  
  archetype_term = ArchetypeTerm.new(:code => 'at0000',
                                     :items => {'text' => 'simple test',
                                       'description' => 'simple test for serializer'})
  term_definitions = {'ja' => [archetype_term]}
  ontology =
    ArchetypeOntology.new(:specialisation_depth => 0,
                          :term_definitions => term_definitions)
  archetype_id = ArchetypeID.new(:value => 
                                 'openEHR-EHR-SECTION.test.v1')
  terminology_id = TerminologyID.new(:value => 'ISO_639-1')
  original_language = CodePhrase.new(:code_string => 'ja',
                                     :terminology_id => terminology_id)
  occurrences = Interval.new(:upper => 1, :lower => 1)
  definition = CComplexObject.new(:path => '/',
                                  :rm_type_name => 'SECTION',
                                  :occurrences => occurrences,
                                  :node_id => 'at0000')
  original_author = {'email' => 'skoba@moss.gr.jp',
    'organisation' => 'openEHR.jp',
    'name' => 'Shinji KOBAYASHI'}
  resource_description_item =
    ResourceDescriptionItem.new(:language => original_language,
                                :purpose => 'Serializer test',
                                :misuse => 'evaluate message')
  details = {'ja' => resource_description_item}
  description = ResourceDescription.new(:original_author => original_author,
                                        :lifecycle_state => 'draft',
                                        :details => details)
  return archetype = Archetype.new(:archetype_id => archetype_id,
                                   :concept => 'at0000',
                                   :original_language => original_language,
                                   :ontology => ontology,
                                   :description => description,
                                   :definition => definition)
end
