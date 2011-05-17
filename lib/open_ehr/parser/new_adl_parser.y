class OpenEHR::Parser::ADLParser

#options omit_action_call

prechigh

  nonassoc UMINUS UPLUS
  left '*' '/'
  left '+' '-'

  nonassoc SYM_EQ
  nonassoc SYM_NE
  nonassoc SYM_LT
  nonassoc SYM_START_DBLOCK
  nonassoc SYM_START_CBLOCK
  nonassoc SYM_GT
  nonassoc SYM_END_CBLOCK
  nonassoc SYM_END_DBLOCK
  nonassoc SYM_LE
  nonassoc SYM_GE

preclow


rule
### http://svn.openehr.org/ref_impl_eiffel/TRUNK/components/adl_parser/src/syntax/adl/parser/adl_validator.y

input: archetype EOF
  { 
    result = val[0]
  }
  | error

archetype: arch_identification arch_specialisation arch_concept arch_language arch_description arch_definition arch_invariant arch_ontology
  { 
    assert_at(__FILE__,__LINE__) do
      val[4].instance_of?(OpenEHR::AM::Archetype::ArchetypeDescription::ARCHETYPE_DESCRIPTION) and val[5].instance_of?(OpenEHR::AM::Archetype::ConstraintModel::CComplexObject) and val[7].instance_of?(OpenEHR::AM::Archetype::Ontology::ArchetypeOntology) 
    end
    
    archetype_id = val[0][:archetype_id]
    parent_archtype_id = val[1][:parent_archtype_id] if val[1]
    adl_version = val[0][:arch_head][:arch_meta_data][:adl_version]
    concept = val[2][:arch_concept]
    language = val[3][:arch_language]
    archetype = OpenEHR::AM::Archetype::Archetype.create(
                                                         :archetype_id => archetype_id,
                                                         :parent_archtype_id => parent_archtype_id,
                                                         :adl_version => adl_version,
                                                         :concept => concept,
                                                         :description => val[4],
                                                         :definition => val[5],
                                                         :ontology => val[7]
                                                         ) do |archetype|
      archetype.original_language = language
    end
    @@logger.debug("#{__FILE__}:#{__LINE__}: archetype = #{archetype.to_yaml} at #{@filename}:#{@lineno}")
    result = archetype
  }


arch_identification: arch_head V_ARCHETYPE_ID
  { 
    result = {:arch_head => val[0], :archetype_id => val[1] }
  }
  | SYM_ARCHETYPE error
  { 
    raise
  }

arch_head: SYM_ARCHETYPE
  { 
    result = {:arch_meta_data => nil }
  }
  | SYM_ARCHETYPE arch_meta_data
  { 
    result = val[1]
  }

arch_meta_data: Left_parenthesis_code arch_meta_data_items Right_parenthesis_code
  { 
    result = {:arch_meta_data => val[1] }
  }

arch_meta_data_items: arch_meta_data_item
  { 
    result = val[0]
  }
  | arch_meta_data_items Semicolon_code arch_meta_data_item
  { 
    result = val[0].merge(val[2])
  }


arch_meta_data_item: SYM_ADL_VERSION SYM_EQ V_VERSION_STRING
  { 
    result = {:adl_version => val[2], :is_controlled => false }
  }
  | SYM_IS_CONTROLLED
  { 
    result = {:is_controlled => true }
  }

# Define specialization in which its constraints are narrower than those of the parent.
# Any data created via the use of the specialized archetype shall be conformant both to it and its parent.
arch_specialisation: #-- empty is ok
  | SYM_SPECIALIZE V_ARCHETYPE_ID
  {
    result = {:parent_archtype_id => val[1]}
  }
  | SYM_SPECIALIZE error

arch_concept: SYM_CONCEPT V_LOCAL_TERM_CODE_REF
  { 
    result = {:arch_concept => val[1] }
  }
  | SYM_CONCEPT error

#arch_language: #-- empty is ok for ADL 1.4 tools
#    | SYM_LANGUAGE V_DADL_TEXT
#  | SYM_LANGUAGE error

arch_language: #-- empty is ok for ADL 1.4 tools
  {
    result = {:arch_language => ""}
  }
    | SYM_LANGUAGE dadl_section
  {
    dadl_section = val[1]
    @@logger.debug("#{__FILE__}:#{__LINE__}: arch_language::dadl_section = \n#{dadl_section.to_yaml}")
    case dadl_section[:attr_id]
    when "translations"
      result = {:arch_language => dadl_section[:object_block][:untyped_primitive_object_block]}
    when "original_language"
      result = {:arch_language => dadl_section[:object_block][:untyped_primitive_object_block]}
###     if val[1][:attr_id] == "original_language"
###       result = {:arch_language => val[0][:object_block][:untyped_primitive_object_block]}
    else
      raise OpenEHR::Parser::Exception::Parser::Error, "It should be 'original_language, but was #{dadl_section[:attr_id]}' at #{@filename}:#{@lineno} "
    end
  }
  | SYM_LANGUAGE error

#arch_description: #-- no meta-data ok
#    | SYM_DESCRIPTION V_DADL_TEXT
#  | SYM_DESCRIPTION error

arch_description: #-- no meta-data ok
    | SYM_DESCRIPTION dadl_section
  { 
    dadl_section = val[1]
    args = Hash.new
    @@logger.debug("#{__FILE__}:#{__LINE__}: arch_description: val[1].class = \n#{val[1].class} at #{@filename}:#{@lineno}")
#    val[1].each do |item|
#      @@logger.debug("#{__FILE__}:#{__LINE__}: arch_description: item = \n#{item.to_yaml} at #{@filename}:#{@lineno}")
#      case item[:attr_id]
      case dadl_section[:attr_id]
      when "original_author"
#        unless item[:object_block][:type_identifier]
        unless dadl_section[:object_block][:type_identifier]
#          args.merge!(Hash[:original_author => item[:untyped_multiple_attr_object_block]])
          args.merge!(Hash[:original_author => dadl_section[:untyped_multiple_attr_object_block]])
        else
          raise OpenEHR::Parser::Exception::Parser::Error, "Needless type_identifier at #{@filename}:#{@lineno} "
        end
      when "details"
#        unless item[:type_identifier]
        unless dadl_section[:type_identifier]
#          args.merge!(Hash[:details => item[:untyped_multiple_attr_object_block]])
          #args.merge!(Hash[:details => item[:object_block]])
          args.merge!(Hash[:details => dadl_section[:untyped_multiple_attr_object_block]])
        else
          raise OpenEHR::Parser::Exception::Parser::Error, "Needless type_identifier at #{@filename}:#{@lineno} "
        end
      when "lifecycle_state"
#        unless item[:type_identifier]
        unless dadl_section[:type_identifier]
#          args.merge!(Hash[:lifecycle_state => item[:untyped_primitive_object_block]])
          args.merge!(Hash[:lifecycle_state => dadl_section[:untyped_primitive_object_block]])
        else
          raise OpenEHR::Parser::Exception::Parser::Error, "Needless type_identifier at #{@filename}:#{@lineno} "
        end
      when "other_contributors"
#        unless item[:type_identifier]
        unless dadl_section[:type_identifier]
#          args.merge!(Hash[:other_contributors => item[:untyped_multiple_attr_object_block]])
          args.merge!(Hash[:other_contributors => dadl_section[:untyped_multiple_attr_object_block]])
        else
          raise OpenEHR::Parser::Exception::Parser::Error, "Needless type_identifier at #{@filename}:#{@lineno} "
        end
      when "other_details"
#        unless item[:type_identifier]
        unless dadl_section[:type_identifier]
#          args.merge!(Hash[:other_contributors => item[:untyped_multiple_attr_object_block]])
          args.merge!(Hash[:other_contributors => dadl_section[:untyped_multiple_attr_object_block]])
        else
          raise OpenEHR::Parser::Exception::Parser::Error, "Needless type_identifier at #{@filename}:#{@lineno} "
        end
      else
#        raise OpenEHR::Parser::Exception::Parser::Error, "Unknown case #{item} at #{@filename}:#{@lineno} "
        raise OpenEHR::Parser::Exception::Parser::Error, "Unknown case #{dadl_section} at #{@filename}:#{@lineno} "
      end
#    end
    @@logger.debug("#{__FILE__}:#{__LINE__}: arch_description: args  = \n#{args.to_yaml} at #{@filename}:#{@lineno}")
    result = OpenEHR::AM::Archetype::ArchetypeDescription::ARCHETYPE_DESCRIPTION.new(args)
  }
  | SYM_DESCRIPTION error
  
#arch_definition: SYM_DEFINITION V_CADL_TEXT
#  | SYM_DEFINITION error
arch_definition: SYM_DEFINITION cadl_section
  { 
    result = val[1]
  }
  | SYM_DEFINITION error


### cADL section
cadl_section: c_complex_object
  {
    assert_at(__FILE__,__LINE__){val[0].instance_of?(OpenEHR::AM::Archetype::ConstraintModel::C_COMPLEX_OBJECT)}
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_complex_object = #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | assertions
  { 
    result = val[0]
  }
#  | error

### c_complex_object: c_complex_object_head SYM_MATCHES SYM_START_CBLOCK c_complex_object_body SYM_END_CBLOCK
#  | c_complx_object_head SYM_MATCHES Slash_code REGEXP_BODY Slash_code # added by akimichi
c_complex_object:  c_complx_object_head SYM_MATCHES REGEXP_HEAD REGEXP_BODY # added by akimichi
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}:c_complx_object = \n c_complx_object_head = #{val[0].to_yaml}")
    result = OpenEHR::AM::Archetype::ConstraintModel::C_COMPLEX_OBJECT.create(:attributes => val[3]) do |c_complex_object|
      c_complex_object.node_id = val[0][:c_complex_object_id][:local_term_code_ref]
      c_complex_object.rm_type_name = val[0][:c_complex_object_id][:type_identifier]
      c_complex_object.occurrences = val[0][:c_occurrences]
    end
  }
#c_complex_object: c_complex_object_head SYM_MATCHES SYM_START_CBLOCK c_complex_object_body SYM_END_CBLOCK
  | c_complex_object_head SYM_MATCHES SYM_START_CBLOCK c_complex_object_body SYM_END_CBLOCK
  { 
    result = OpenEHR::AM::Archetype::ConstraintModel::C_COMPLEX_OBJECT.create(:attributes => val[3]) do |c_complex_object|
      c_complex_object.node_id = val[0][:c_complex_object_id][:local_term_code_ref]
      c_complex_object.rm_type_name = val[0][:c_complex_object_id][:type_identifier]
      c_complex_object.occurrences = val[0][:c_occurrences]
    end
  }

#    | c_complex_object_head error SYM_END_CBLOCK
#    | c_complex_object_head SYM_MATCHES SYM_START_CBLOCK c_complex_object_body c_invariants SYM_END_CBLOCK

c_complex_object_head: c_complex_object_id c_occurrences
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_complex_object_head: c_complex_object_id => #{val[0]}, c_occurrences => #{val[1]}")
    result = {:c_complex_object_id => val[0], :c_occurrences => val[1]}
  }

c_complex_object_id: type_identifier
  {
    result = {:type_identifier => val[0]}
  }
  | type_identifier V_LOCAL_TERM_CODE_REF
  {
    result = {:type_identifier => val[0], :local_term_code_ref => val[1]}
  }

c_complex_object_body: c_any #-- used to indicate that any value of a type is ok
  | c_attributes
  { 
    result = OpenEHR::AM::Archetype::ConstraintModel::C_COMPLEX_OBJECT.new(:attributes => val[0])
  }


#------------------------- node types -----------------------
### http://www.openehr.org/svn/ref_impl_eiffel/TRUNK/components/adl_parser/src/syntax/cadl/parser/cadl_validator.html
### c_object:  c_complex_object
### | archetype_internal_ref
### | archetype_slot
### | constraint_ref
### | c_code_phrase
### | c_ordinal
### | c_primitive_object
### | V_C_DOMAIN_TYPE
### | ERR_C_DOMAIN_TYPE
### | error
c_object: c_complex_object
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_complex_object = #{val[0].inspect} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | archetype_internal_ref
  {
    result = OpenEHR::AM::Archetype::ConstraintModel::ARCHETYPE_INTERNAL_REF.create do |archetype_internal_ref|
      archetype_internal_ref.target_path = val[0][:absolute_path]
      archetype_internal_ref.rm_type_name = val[0][:type_identifier]
      archetype_internal_ref.occurrences = val[0][:c_occurrences]
    end
  }
  | archetype_slot
  {
    result = val[0]
  }
  | constraint_ref
  {
    result = OpenEHR::AM::Archetype::ConstraintModel::CONSTRAINT_REF.create do |constraint_ref|
      constraint_ref.reference = val[0]
    end
  }
  | c_code_phrase
  {
    result = val[0]
  }
  | c_ordinal
  {
    result = val[0]
  }
  | c_primitive_object
  {
    result = val[0]
  }
  | v_c_domain_type
  {
    result = val[0]
  }
#  | v_c_domain_type
#  | V_C_DOMAIN_TYPE
  #   this is an attempt to match a dADL section inside cADL. It will
  #   probably never work 100% properly since there can be '>' inside "||"
  #   ranges, and also strings containing any character, e.g. units string
  #   contining "{}" chars. The real solution is to use the dADL parser on
  #   the buffer from the current point on and be able to fast-forward the
  #   cursor to the last character matched by the dADL scanner
### ----------/* V_C_DOMAIN_TYPE - sections of dADL syntax */ -------------------------------------------------  	----------/* V_C_DOMAIN_TYPE - sections of dADL syntax */ -------------------------------------------------
	
	
### [A-Z][a-zA-Z0-9_]*[ \n]*< { -- match a pattern like 'Type_Identifier whitespace <' 	[A-Z][a-zA-Z0-9_]*[ \n]*< { -- match a pattern like 'Type_Identifier whitespace <'
###                 set_start_condition (IN_C_DOMAIN_TYPE) 	                set_start_condition (IN_C_DOMAIN_TYPE)
###             } 	            }
	
### <IN_C_DOMAIN_TYPE>[^}>]*>[ \n]*[^>}A-Z] { -- match up to next > not followed by a '}' or '>' 	<IN_C_DOMAIN_TYPE>[^}>]*>[ \n]*[^>}A-Z] { -- match up to next > not followed by a '}' or '>'
###                  in_buffer.append_string (text) 	                 in_buffer.append_string (text)
###              } 	             }
	
### <IN_C_DOMAIN_TYPE>[^}>]*>+[ \n]*[}A-Z] { -- final section - '...> whitespace } or beginning of a type identifier' 	<IN_C_DOMAIN_TYPE>[^}>]*>+[ \n]*[}A-Z] { -- final section - '...> whitespace } or beginning of a type identifier'

### <IN_C_DOMAIN_TYPE>[^}>]*[ \n]*} { -- match up to next '}' not preceded by a '>' 	<IN_C_DOMAIN_TYPE>[^}>]*[ \n]*} { -- match up to next '}' not preceded by a '>'
###                  in_buffer.append_string (text) 	                 in_buffer.append_string (text)
###               } 	              }
	

  | ERR_C_DOMAIN_TYPE
  | error

v_c_domain_type: START_V_C_DOMAIN_TYPE_BLOCK dadl_section END_V_C_DOMAIN_TYPE_BLOCK
  { 
    result = val[1]
  }

# 'archetype_internal_ref' is a node that refers to a previously defined object node in the same archetype.
archetype_internal_ref: SYM_USE_NODE type_identifier c_occurrences absolute_path
  {
    result = {:type_identifier => val[1], :c_occurrences => val[2], :absolute_path => val[3] }
  }
  | SYM_USE_NODE type_identifier error

# 'archetype_slot' is a node whose statements define a constraint that determines which other archetypes may appear at that point in the current archetype.
archetype_slot: c_archetype_slot_head SYM_MATCHES SYM_START_CBLOCK c_includes c_excludes SYM_END_CBLOCK
  {
    result = OpenEHR::AM::Archetype::ConstraintModel::ARCHETYPE_SLOT.create do |archetype_slot|
      archetype_slot.includes = val[3]
      archetype_slot.excludes = val[4]
      archetype_slot.rm_type_name = val[0][:c_archetype_slot_id]
      archetype_slot.occurrences = val[0][:c_occurrences]
    end
  }
c_archetype_slot_head: c_archetype_slot_id c_occurrences
  {
    result = {:c_archetype_slot_id => val[0],:c_occurrences => val[1]}
  }

c_archetype_slot_id: SYM_ALLOW_ARCHETYPE type_identifier
  {
    result = val[1]
  }
  | SYM_ALLOW_ARCHETYPE type_identifier V_LOCAL_TERM_CODE_REF
  | SYM_ALLOW_ARCHETYPE error

# 'c_primitive_object' is an node representing a constraint on a primitive object type.
c_primitive_object: c_primitive
  {
    assert_at(__FILE__,__LINE__){val[0].kind_of?(OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_PRIMITIVE)}
    result = OpenEHR::AM::Archetype::ConstraintModel::C_PRIMITIVE_OBJECT.create do |c_primitive_object|
      c_primitive_object.item = val[0]
    end
  }

c_primitive: c_integer
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_integer = #{val[0]} at #{@filename}:#{@lineno}")
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_INTEGER.create do |c_integer|
      c_integer.list
      c_integer.range
      c_integer.assumed_value
    end
  }
  | c_real
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_real = #{val[0]} at #{@filename}:#{@lineno}")
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_REAL.new
  }
  | c_date
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_date = #{val[0]} at #{@filename}:#{@lineno}")
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_DATE.new
  }
  | c_time
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_time = #{val[0]} at #{@filename}:#{@lineno}")
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_TIME.new
  }
  | c_date_time
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_date_time = #{val[0]} at #{@filename}:#{@lineno}")
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_DATE_TIME.new
  }
  | c_duration
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_duration = #{val[0]} at #{@filename}:#{@lineno}")
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_DURATION.new
  }
  | c_string
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_string = #{val[0]} at #{@filename}:#{@lineno}")
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_STRING.new
  }
  | c_boolean
  {
    assert_at(__FILE__,__LINE__){val[0].instance_of?(OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_BOOLEAN)}
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_boolean = #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }

c_any: Star_code
#c_any: '*'

#---------------- BODY - relationships ----------------

c_attributes: c_attribute
  { 
    result = [val[0]]
  }
  | c_attributes c_attribute
  { 
    result = (val[0] << val[1])
  }

# 'c_attribute' is a node representing a constraint on an attribute in an object model.
c_attribute: c_attr_head SYM_MATCHES SYM_START_CBLOCK c_attr_values SYM_END_CBLOCK
  { 
    @@logger.debug("#{__FILE__}:#{__LINE__}:c_attribute: #{val[0]} matches #{val[3]}")
    assert_at(__FILE__,__LINE__){ val[0].kind_of?(OpenEHR::AM::Archetype::ConstraintModel::C_ATTRIBUTE)}
    c_attribute = val[0]
    c_attribute.children = val[3]
    result = c_attribute
  }
  | c_attr_head SYM_MATCHES REGEXP_HEAD REGEXP_BODY SYM_END_CBLOCK # added by akimichi
  {
    @@logger.debug("c_attribute: #{val[0]} matches #{val[3]}}")
    assert_at(__FILE__,__LINE__){ val[0].kind_of?(OpenEHR::AM::Archetype::ConstraintModel::C_ATTRIBUTE)}
    result = val[0]
  }
  | c_attr_head SYM_MATCHES REGEXP_HEAD REGEXP_BODY Semicolon_code string_value SYM_END_CBLOCK # added by akimichi

  {
    @@logger.debug("c_attribute: #{val[0]} matches #{val[5]}}")
    assert_at(__FILE__,__LINE__){ val[0].kind_of?(OpenEHR::AM::Archetype::ConstraintModel::C_ATTRIBUTE)}
    result = val[0]
  }
  | c_attr_head SYM_MATCHES SYM_START_CBLOCK error SYM_END_CBLOCK
  { 
    assert_at(__FILE__,__LINE__){ val[0].kind_of?(OpenEHR::AM::Archetype::ConstraintModel::C_ATTRIBUTE)}
    result = val[0]
  }


c_attr_head: V_ATTRIBUTE_IDENTIFIER c_existence
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: V_ATTRIBUTE_IDENTIFIER = #{val[0]}, c_existence = #{val[1]} at #{@filename}")
    result = OpenEHR::AM::Archetype::ConstraintModel::C_SINGLE_ATTRIBUTE.new(
                                                                              :rm_attribute_name => val[0],
                                                                              :existence => val[1]
                                                                              )

  }
  | V_ATTRIBUTE_IDENTIFIER c_existence c_cardinality
  {
    assert_at(__FILE__,__LINE__){ val[2].instance_of?(OpenEHR::AM::Archetype::ConstraintModel::CARDINALITY) }
    @@logger.debug("#{__FILE__}:#{__LINE__}: V_ATTRIBUTE_IDENTIFIER: #{val[0]}, c_existence = #{val[1]}, c_cardinality = #{val[2]} at #{@filename}") 
    result = OpenEHR::AM::Archetype::ConstraintModel::C_MULTIPLE_ATTRIBUTE.new(
                                                                                :rm_attribute_name => val[0],
                                                                                :existence => val[1],
                                                                                :cardinality => val[2]
                                                                                )
  }

c_attr_values: c_object
  { 
    result = Array[val[0]]
  }
  | c_attr_values c_object
  { 
    result = (val[0] << val[1])
  }
  | c_any #	-- to allow a property to have any value
  { 
    result = Array[val[0]]
  }

c_includes: #-- Empty
    | SYM_INCLUDE assertions
{
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_includes: assertions = #{val[1]}") 
    result = val[1]
}
### c_includes: #-- Empty
###     | SYM_INCLUDE invariants

c_excludes: #-- Empty
    | SYM_EXCLUDE assertions
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: c_excludes: assertions = #{val[1]}") 
    result = val[1]
  }
### c_excludes: #-- Empty
###     | SYM_EXCLUDE invariants

invariants: invariant
  | invariants invariant

invariant: any_identifier Colon_code boolean_expression
  | boolean_expression
  | any_identifier Colon_code error

arch_invariant: #-- no invariant ok
    | SYM_INVARIANT V_ASSERTION_TEXT
    | SYM_INVARIANT error

# define all linguistic entries in this part as dADL.
#arch_ontology: SYM_ONTOLOGY V_DADL_TEXT
#  | SYM_ONTOLOGY error

arch_ontology: SYM_ONTOLOGY dadl_section
  { 
    dadl_section = val[1]
    @@logger.debug("#{__FILE__}:#{__LINE__}: arch_ontology: dadl_section = \n#{dadl_section.to_yaml}") 
    args = Hash.new
    case dadl_section[:attr_id]
    when "terminologies_available"
      unless dadl_section[:object_block][:type_identifier]
        args.merge!(Hash[:terminologies_available => dadl_section[:object_block][:untyped_primitive_object_block]])
      else
        raise OpenEHR::Parser::Exception::Parser::Error, "Needless type_identifier at #{@filename}:#{@lineno} "
      end
    when "term_definitions"
      unless dadl_section[:object_block][:type_identifier]
        args.merge!(Hash[:term_definitions => dadl_section[:object_block][:untyped_multiple_attr_object_block]])
      else
        raise OpenEHR::Parser::Exception::Parser::Error, "Needless type_identifier at #{@filename}:#{@lineno} "
      end
    when "term_binding"
      unless dadl_section[:object_block][:type_identifier]
        args.merge!(Hash[:term_binding => dadl_section[:object_block][:untyped_multiple_attr_object_block]])
      else
        raise OpenEHR::Parser::Exception::Parser::Error, "Needless type_identifier at #{@filename}:#{@lineno} "
      end
    else
      raise OpenEHR::Parser::Exception::Parser::Error, "Unknown case #{dadl_section[:attr_id]} at #{@filename}:#{@lineno} "
    end
###     dadl_section.each do |item|
###       @@logger.debug("#{__FILE__}:#{__LINE__}: arch_description: item[:object_block] = #{item[:object_block].to_yaml} at #{@filename}:#{@lineno}")
###       case item[:attr_id]
###       when "terminologies_available"
###         unless item[:object_block][:type_identifier]
###           args.merge!(Hash[:terminologies_available => item[:object_block][:untyped_primitive_object_block]])
###         else
###           raise OpenEHR::Parser::Exception::Parser::Error, "Needless type_identifier at #{@filename}:#{@lineno} "
###         end
###       when "term_definitions"
###         unless item[:object_block][:type_identifier]
###           args.merge!(Hash[:term_definitions => item[:object_block][:untyped_multiple_attr_object_block]])
###         else
###           raise OpenEHR::Parser::Exception::Parser::Error, "Needless type_identifier at #{@filename}:#{@lineno} "
###         end
###       when "term_binding"
###         unless item[:object_block][:type_identifier]
###           args.merge!(Hash[:term_binding => item[:object_block][:untyped_multiple_attr_object_block]])
###         else
###           raise OpenEHR::Parser::Exception::Parser::Error, "Needless type_identifier at #{@filename}:#{@lineno} "
###         end
###       else
###         raise OpenEHR::Parser::Exception::Parser::Error, "Unknown case #{item[:attr_id]} at #{@filename}:#{@lineno} "
###       end
###     end

    result = OpenEHR::AM::Archetype::Ontology::ARCHETYPE_ONTOLOGY.new(args)
  }
  | SYM_ONTOLOGY error


### dParser section
dadl_section: # no dadl section
    |  attr_vals
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}:dadl_section::attr_vals = \n#{val[0].to_yaml}")
    result = val[0]
  }
  | complex_object_block
  {
    #@@logger.debug("#{__FILE__}:#{__LINE__}:dadl_section::complex_object_block = \n#{val[0].to_yaml}")
    result = val[0]
  }
#  | error

attr_vals: attr_val
  {
    attr_val = val[0]
    result = Hash[attr_val[:attr_id] => attr_val[:object_block]]
  }
  | attr_vals attr_val
  {
    result = val[0].merge!(val[1])
  }
  | attr_vals Semicolon_code attr_val
  {
    result = val[0].merge!(val[2])
  }
### attr_vals: attr_val
###   {
###     result = Array[val[0]]
###   }
###   | attr_vals attr_val
###   {
###     result = (val[0] << val[1])
###   }
###   | attr_vals Semicolon_code attr_val
###   {
###     result = (val[0] << val[2])
###   }

attr_val: attr_id SYM_EQ object_block
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}:attr_val\n attr_id = #{val[0].to_yaml},\n object_block = #{val[2].to_yaml}")
    result = {:attr_id => val[0], :object_block => val[2]}
  }

attr_id: V_ATTRIBUTE_IDENTIFIER
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: V_ATTRIBUTE_IDENTIFIER = #{val[0]}")
    result = val[0]
  }
  | V_ATTRIBUTE_IDENTIFIER error

object_block: complex_object_block
  { 
    result = val[0]
  }
  | primitive_object_block
  { 
    result = val[0]
  }

complex_object_block: single_attr_object_block
  { 
    result = val[0]
  }
  | multiple_attr_object_block
  { 
    result = val[0]
  }

multiple_attr_object_block: untyped_multiple_attr_object_block
  { 
    @@logger.debug("#{__FILE__}:#{__LINE__}:multiple_attr_object_block::attr_val\n untyped_multiple_attr_object_block = #{val[0].to_yaml}")
    result = {:untyped_multiple_attr_object_block => val[0]}
  }
  | type_identifier untyped_multiple_attr_object_block
  { 
    result = {:type_identifier => val[0], :untyped_multiple_attr_object_block => val[1]}
  }

untyped_multiple_attr_object_block: multiple_attr_object_block_head keyed_objects SYM_END_DBLOCK
  { 
    @@logger.debug("#{__FILE__}:#{__LINE__}:untyped_multiple_attr_object_block::keyed_objects\n keyed_objects = #{val[1].to_yaml}")
    result = val[1]
  }

multiple_attr_object_block_head: SYM_START_DBLOCK
  { 
    result = val[0]
  }

keyed_objects: keyed_object
  { 
    result = Array[val[0]]
  }
  | keyed_objects keyed_object
  { 
    result = (val[0] << val[1])
  }

keyed_object: object_key SYM_EQ object_block
  {
    #@@logger.debug("#{__FILE__}:#{__LINE__}: keyed_object = #{val[0]} at #{@filename}:#{@lineno}")
    #result = {:object_key => val[0], :object_block => val[2]}
    object_key,object_block = val[0],val[2]
    unless object_block[:type_identifier]
      result = Hash[val[0] => object_block[:untyped_primitive_object_block]]
    else
      raise OpenEHR::Parser::Exception::Parser::Error, "Missing type_identifier at #{@filename}:#{@lineno} "
    end
  }

object_key: Left_bracket_code simple_value Right_bracket_code
  {
    @@logger.debug("object_key: [#{val[1]}] at #{@filename}:#{@lineno}")
    result = val[1]
  }

single_attr_object_block: untyped_single_attr_object_block
  {
    result = {:untyped_single_attr_object_block => val[0]}
  }
  | type_identifier untyped_single_attr_object_block
  {
    result = {:type_identifier => val[0], :untyped_single_attr_object_block => val[1]}
  }

untyped_single_attr_object_block: single_attr_object_complex_head SYM_END_DBLOCK # >
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: single_attr_object_complex_head = #{val[0]} at #{@filename}:#{@lineno}")
    result = []
  }
  | single_attr_object_complex_head attr_vals SYM_END_DBLOCK
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: untyped_single_attr_object_block::attr_vals = \n#{val[1].to_yaml} at #{@filename}:#{@lineno}")
    result = val[1]
  }
single_attr_object_complex_head: SYM_START_DBLOCK

primitive_object_block: untyped_primitive_object_block
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: untyped_primitive_object_block = #{val[0]} at #{@filename}:#{@lineno}")
    result = {:untyped_primitive_object_block => val[0]}
  }
  | type_identifier untyped_primitive_object_block
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: type_identifier = #{val[0]}, untyped_primitive_object_block = #{val[1]} at #{@filename}:#{@lineno}")
    result = {:type_identifier => val[0], :untyped_primitive_object_block => val[1]}
  }
untyped_primitive_object_block: SYM_START_DBLOCK primitive_object_value SYM_END_DBLOCK
  {
    #@@logger.debug("#{__FILE__}:#{__LINE__}: primitive_object_block = <#{val[1]}> at #{@filename}:#{@lineno}")
    result = val[1]
  }
primitive_object_value: simple_value
  {
    result = val[0]
  }
  | simple_list_value
  {
    result = val[0]
  }
  | simple_interval_value
  {
    result = val[0]
  }
  | term_code
  {
    result = val[0]
  }
  | term_code_list_value
  {
    result = val[0]
  }
simple_value: string_value
  {
    @@logger.debug("string_value: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | integer_value
  {
    @@logger.debug("integer_value: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | real_value
  {
    @@logger.debug("real_value: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | boolean_value
  {
    @@logger.debug("boolean_value: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | character_value
  {
    @@logger.debug("character_value: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | date_value
  {
    @@logger.debug("date_value: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | time_value
  {
    @@logger.debug("time_value: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | date_time_value
  {
    @@logger.debug("date_time_value: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | duration_value
  {
    @@logger.debug("duration_value: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | uri_value
  {
    @@logger.debug("uri_value: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }

simple_list_value: string_list_value
  {
    @@logger.debug("string_list_value: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | integer_list_value
  {
    result = val[0]
  }
  | real_list_value
  {
    result = val[0]
  }
  | boolean_list_value
  {
    result = val[0]
  }
  | character_list_value
  {
    result = val[0]
  }
  | date_list_value
  {
    result = val[0]
  }
  | time_list_value
  {
    result = val[0]
  }
  | date_time_list_value
  {
    result = val[0]
  }
  | duration_list_value
  {
    result = val[0]
  }

simple_interval_value: integer_interval_value
  | real_interval_value
  | date_interval_value
  | time_interval_value
  | date_time_interval_value
  | duration_interval_value

type_identifier: V_TYPE_IDENTIFIER
  {
    @@logger.debug("V_TYPE_IDENTIFIER: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }
  | V_GENERIC_TYPE_IDENTIFIER
  {
    @@logger.debug("V_GENERIC_TYPE_IDENTIFIER: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }

string_value: V_STRING
  {
    @@logger.debug("V_STRING: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }

string_list_value: V_STRING Comma_code V_STRING
  {
    result = [val[0],val[2]]
  }
  | string_list_value Comma_code V_STRING
  {
    result = val[0] << val[2]
  }
  | V_STRING Comma_code SYM_LIST_CONTINUE
  {
    result = val[0]
  }

integer_value: V_INTEGER
  { 
    begin
      integer = Integer(val[0])
    rescue
      raise
    end
    result = integer
  }
  | Plus_code V_INTEGER
  {
    begin
      integer = Integer(val[0])
    rescue
      raise
    end
    result = integer
  }
  | Minus_code V_INTEGER
  {
    begin
      integer = Integer(val[0])
    rescue
      raise
    end
    result = - integer
  }

integer_list_value: integer_value Comma_code integer_value
  | integer_list_value Comma_code integer_value
  | integer_value Comma_code SYM_LIST_CONTINUE

integer_interval_value: SYM_INTERVAL_DELIM integer_value SYM_ELLIPSIS integer_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT integer_value SYM_ELLIPSIS integer_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM integer_value SYM_ELLIPSIS SYM_LT integer_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT integer_value SYM_ELLIPSIS SYM_LT integer_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LT integer_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LE integer_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT integer_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GE integer_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM integer_value SYM_INTERVAL_DELIM

real_value: V_REAL
  {
    begin
      real = Float(val[0])
    rescue
      raise
    end
    result = real
  }
  | Plus_code V_REAL
  {
    begin
      real = Float(val[1])
    rescue
      raise
    end
    result = real
  }
  | Minus_code V_REAL
  {
    begin
      real = Float(val[1])
    rescue
      raise
    end
    result = - real
  }

real_list_value: real_value Comma_code real_value
  | real_list_value Comma_code real_value
  | real_value Comma_code SYM_LIST_CONTINUE

real_interval_value: SYM_INTERVAL_DELIM real_value SYM_ELLIPSIS real_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT real_value SYM_ELLIPSIS real_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM real_value SYM_ELLIPSIS SYM_LT real_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT real_value SYM_ELLIPSIS SYM_LT real_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LT real_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LE real_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT real_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GE real_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM real_value SYM_INTERVAL_DELIM


boolean_value: SYM_TRUE
  { 
    result = true
  }
  | SYM_FALSE
  { 
    result = false
  }

boolean_list_value: boolean_value Comma_code boolean_value
  | boolean_list_value Comma_code boolean_value
  | boolean_value Comma_code SYM_LIST_CONTINUE

character_value: V_CHARACTER

character_list_value: character_value Comma_code character_value
  | character_list_value Comma_code character_value
  | character_value Comma_code SYM_LIST_CONTINUE

date_value: V_ISO8601_EXTENDED_DATE
  { 
    result = val[0]
  }

date_list_value: date_value Comma_code date_value
  | date_list_value Comma_code date_value
  | date_value Comma_code SYM_LIST_CONTINUE

date_interval_value: SYM_INTERVAL_DELIM date_value SYM_ELLIPSIS date_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT date_value SYM_ELLIPSIS date_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM date_value SYM_ELLIPSIS SYM_LT date_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT date_value SYM_ELLIPSIS SYM_LT date_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LT date_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LE date_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT date_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GE date_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM date_value SYM_INTERVAL_DELIM

time_value: V_ISO8601_EXTENDED_TIME

time_list_value: time_value Comma_code time_value
  | time_list_value Comma_code time_value
  | time_value Comma_code SYM_LIST_CONTINUE

time_interval_value: SYM_INTERVAL_DELIM time_value SYM_ELLIPSIS time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT time_value SYM_ELLIPSIS time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM time_value SYM_ELLIPSIS SYM_LT time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT time_value SYM_ELLIPSIS SYM_LT time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LT time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LE time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GE time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM time_value SYM_INTERVAL_DELIM

date_time_value: V_ISO8601_EXTENDED_DATE_TIME
  {
    @@logger.debug("V_ISO8601_EXTENDED_DATE_TIME: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }

date_time_list_value: date_time_value Comma_code date_time_value
  | date_time_list_value Comma_code date_time_value
  | date_time_value Comma_code SYM_LIST_CONTINUE

date_time_interval_value: SYM_INTERVAL_DELIM date_time_value SYM_ELLIPSIS date_time_value  SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT date_time_value SYM_ELLIPSIS date_time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM date_time_value SYM_ELLIPSIS SYM_LT date_time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT date_time_value SYM_ELLIPSIS SYM_LT date_time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LT date_time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LE date_time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT date_time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GE date_time_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM date_time_value SYM_INTERVAL_DELIM

duration_value: V_ISO8601_DURATION
  {
    @@logger.debug("V_ISO8601_DURATION: #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }

duration_list_value: duration_value Comma_code duration_value
  | duration_list_value Comma_code duration_value
  | duration_value Comma_code SYM_LIST_CONTINUE

duration_interval_value: SYM_INTERVAL_DELIM duration_value SYM_ELLIPSIS duration_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT duration_value SYM_ELLIPSIS duration_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM duration_value SYM_ELLIPSIS SYM_LT duration_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT duration_value SYM_ELLIPSIS SYM_LT duration_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LT duration_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_LE duration_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GT duration_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM SYM_GE duration_value SYM_INTERVAL_DELIM
  | SYM_INTERVAL_DELIM duration_value SYM_INTERVAL_DELIM

term_code: V_QUALIFIED_TERM_CODE_REF
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: V_QUALIFIED_TERM_CODE_REF = #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }

term_code_list_value: term_code Comma_code term_code
  | term_code_list_value Comma_code term_code
  | term_code Comma_code SYM_LIST_CONTINUE

uri_value: V_URI
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}: V_URI = #{val[0]} at #{@filename}:#{@lineno}")
    result = val[0]
  }


#---------------------- ASSERTIONS ------------------------

assertions: assertion
  | assertions assertion

assertion: any_identifier Colon_code boolean_expression
  | boolean_expression
  | any_identifier Colon_code error

#---------------------- expressions ---------------------

boolean_expression: boolean_leaf
  | boolean_node

boolean_node: SYM_EXISTS absolute_path
#  | SYM_EXISTS error
  | relative_path SYM_MATCHES REGEXP_HEAD REGEXP_BODY SYM_END_CBLOCK# added by akimichi
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}, boolean_node:  relative_path = #{val[0]}, regexp_body => #{val[3]} at #{@filename}") 
    result = {:relative_path => val[0], :regexp_body => val[3]}
  }
  | relative_path SYM_MATCHES SYM_START_CBLOCK c_primitive SYM_END_CBLOCK
#  | relative_path SYM_MATCHES SYM_START_CBLOCK Slash_code REGEXP_BODY Slash_code SYM_END_CBLOCK# added by akimichi
  | SYM_NOT boolean_leaf
  | arithmetic_expression Equal_code arithmetic_expression
  | arithmetic_expression SYM_NE arithmetic_expression
  | arithmetic_expression SYM_LT arithmetic_expression
  | arithmetic_expression SYM_GT arithmetic_expression
  | arithmetic_expression SYM_LE arithmetic_expression
  | arithmetic_expression SYM_GE arithmetic_expression
  | boolean_expression SYM_AND boolean_expression
  | boolean_expression SYM_OR boolean_expression
  | boolean_expression SYM_XOR boolean_expression
  | boolean_expression SYM_IMPLIES boolean_expression

boolean_leaf: Left_parenthesis_code boolean_expression Right_parenthesis_code
  | SYM_TRUE
  | SYM_FALSE

arithmetic_node: arithmetic_expression Plus_code arithmetic_leaf
  | arithmetic_expression Minus_code arithmetic_leaf
  | arithmetic_expression Star_code arithmetic_leaf
  | arithmetic_expression Slash_code arithmetic_leaf
  | arithmetic_expression Caret_code arithmetic_leaf

arithmetic_leaf:  Left_parenthesis_code arithmetic_expression Right_parenthesis_code
  | integer_value
  | real_value
  | absolute_path

arithmetic_expression: arithmetic_leaf
  | arithmetic_node

#--------------- THE FOLLOWING SOURCE TAKEN FROM OG_PATH_VALIDATOR.Y -------------
#--------------- except to remove movable_path ----------------------------------------------------


absolute_path: Slash_code
  | Slash_code relative_path
#  | absolute_path Slash_code relative_path



relative_path: path_segment
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}, relative_path = #{val[0]}") 
    result = val[0]
  }
  | relative_path Slash_code path_segment
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}, relative_path = #{val[0]}/#{val[2]}") 
    result = [val[0],val[2]]
  }

path_segment: V_ATTRIBUTE_IDENTIFIER V_LOCAL_TERM_CODE_REF
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}, V_ATTRIBUTE_IDENTIFIER = #{val[0]} at #{@filename}") 
    result = [val[0],val[1]]
  }
  | V_ATTRIBUTE_IDENTIFIER
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}, V_ATTRIBUTE_IDENTIFIER = #{val[0]} at #{@filename}") 
    result = val[0]
  }


#-------------------------------- END SOURCE TAKEN FROM OG_PATH_VALIDATOR.Y ----------------------


#---------------- existence, occurrences, cardinality ----------------

c_existence: #-- default to 1..1
    { 
    result = Range.new(1,1)
  }
  | SYM_EXISTENCE SYM_MATCHES SYM_START_CBLOCK existence_spec SYM_END_CBLOCK
  { 
    result = val[3]
  }

existence_spec:  V_INTEGER #-- can only be 0 or 1
  { 
    begin
      integer = Integer(val[0])
    rescue
      raise
    end
    result = integer
  }
  | V_INTEGER SYM_ELLIPSIS V_INTEGER #-- can only be 0..0, 0..1, 1..1
  { 
    begin
      from_integer = Integer(val[0])
      to_integer = Integer(val[2])
    rescue
      raise
    end
    result = Range.new(from_integer,to_integer)
  }

c_cardinality: SYM_CARDINALITY SYM_MATCHES SYM_START_CBLOCK cardinality_spec SYM_END_CBLOCK
  { 
    result = OpenEHR::AM::Archetype::ConstraintModel::CARDINALITY.new
  }

cardinality_spec: occurrence_spec
  {
    result = val[0]
  }
  | occurrence_spec Semicolon_code SYM_ORDERED
  | occurrence_spec Semicolon_code SYM_UNORDERED
  | occurrence_spec Semicolon_code SYM_UNIQUE
  | occurrence_spec Semicolon_code SYM_ORDERED Semicolon_code SYM_UNIQUE
  | occurrence_spec Semicolon_code SYM_UNORDERED Semicolon_code SYM_UNIQUE
  | occurrence_spec Semicolon_code SYM_UNIQUE Semicolon_code SYM_ORDERED
  | occurrence_spec Semicolon_code SYM_UNIQUE Semicolon_code SYM_UNORDERED

cardinality_limit_value: integer_value
  {
    result = val[0]
  }
  | Star_code # '*'
  {
    result = val[0]
  }


c_occurrences:  #-- default to 1..1
  | SYM_OCCURRENCES SYM_MATCHES SYM_START_CBLOCK occurrence_spec SYM_END_CBLOCK
  { 
    case val[3]
    when OpenEHR::RM::Support::AssumedTypes::Interval
      result = val[3]
    else
      result = val[3]
    end
  }
  | SYM_OCCURRENCES error

occurrence_spec: cardinality_limit_value #-- single integer or '*'
  { 
    result = val[0]
  }
  | V_INTEGER SYM_ELLIPSIS cardinality_limit_value
  { 
    result = OpenEHR::RM::Support::AssumedTypes::Interval.new(val[0], val[2])
  }

#---------------------- leaf constraint types -----------------------

c_integer_spec: integer_value
  | integer_list_value
  | integer_interval_value

c_integer: c_integer_spec
  | c_integer_spec Semicolon_code integer_value
  | c_integer_spec Semicolon_code error

c_real_spec: real_value
  | real_list_value
  | real_interval_value

c_real: c_real_spec
  | c_real_spec Semicolon_code real_value
  | c_real_spec Semicolon_code error

c_date_constraint: V_ISO8601_DATE_CONSTRAINT_PATTERN
  | date_value
  | date_interval_value

c_date: c_date_constraint
  | c_date_constraint Semicolon_code date_value
  | c_date_constraint Semicolon_code error

c_time_constraint: V_ISO8601_TIME_CONSTRAINT_PATTERN
  | time_value
  | time_interval_value

c_time: c_time_constraint
  | c_time_constraint Semicolon_code time_value
  | c_time_constraint Semicolon_code error

c_date_time_constraint: V_ISO8601_DATE_TIME_CONSTRAINT_PATTERN
  | date_time_value
  | date_time_interval_value

c_date_time: c_date_time_constraint
  | c_date_time_constraint Semicolon_code date_time_value
  | c_date_time_constraint Semicolon_code error

c_duration_constraint: duration_pattern
  | duration_pattern Slash_code duration_interval_value
  | duration_value
  | duration_interval_value

c_duration: c_duration_constraint
  | c_duration_constraint Semicolon_code duration_value
  | c_duration_constraint Semicolon_code error

c_string_spec:  V_STRING #-- single value, generates closed list
  | string_list_value #-- closed list
  | string_list_value Comma_code SYM_LIST_CONTINUE #-- open list
#  | string_list_value ',' SYM_LIST_CONTINUE #-- open list
#  | V_REGEXP #-- regular expression with "//" or "^^" delimiters

c_string: c_string_spec
  | c_string_spec Semicolon_code string_value
  | c_string_spec Semicolon_code error

c_boolean_spec: SYM_TRUE
  { 
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_BOOLEAN.new(:true_valid => true)
  }
  | SYM_FALSE
  { 
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_BOOLEAN.new(:true_valid => false)
  }
  | SYM_TRUE Comma_code SYM_FALSE
  { 
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_BOOLEAN.new(:true_valid => true,:false_valid => false)
  }
  | SYM_FALSE Comma_code SYM_TRUE
  { 
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_BOOLEAN.new(:true_valid => false,:false_valid => true)
  }

c_boolean: c_boolean_spec
  { 
    result = val[0]
  }
  | c_boolean_spec Semicolon_code boolean_value
  {
    result = val[0]
    #raise 'Not implemented yet'
  }
  | c_boolean_spec Semicolon_code error
  {
    raise 'Not implemented yet'
  }

c_ordinal: c_ordinal_spec
  | c_ordinal_spec Semicolon_code integer_value
  | c_ordinal_spec Semicolon_code error

c_ordinal_spec: ordinal
  | c_ordinal_spec Comma_code ordinal

ordinal: integer_value SYM_INTERVAL_DELIM V_QUALIFIED_TERM_CODE_REF
  {
    @in_interval = false
    @@logger.debug("#{__FILE__}:#{__LINE__}, #{val[0]}|#{val[2]} at #{@filename}") 
  }

#c_code_phrase: V_TERM_CODE_CONSTRAINT #-- e.g. "[local::at0040, at0041; at0040]"
c_code_phrase: term_code_constraint_section #-- e.g. "[local::at0040, at0041; at0040]"
  {
      result = val[0]
  }
  | V_QUALIFIED_TERM_CODE_REF
  {
      result = val[0]
  }

#                             [[a-zA-Z0-9\(\)\._\-]+::[ \t\n]*          [[a-zA-Z0-9\._\-]*[ \t]*]
term_code_constraint_section: START_TERM_CODE_CONSTRAINT term_code_body END_TERM_CODE_CONSTRAINT
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}, START_TERM_CODE_CONSTRAINT = #{val[0]} at #{@filename}")
    @@logger.debug("#{__FILE__}:#{__LINE__}, term_code_body = #{val[1]}")
    @@logger.debug("#{__FILE__}:#{__LINE__}, END_TERM_CODE_CONSTRAINT = #{val[2]}")
    result = val[1]
  }


term_code_body: # empty
  | TERM_CODE
  | term_code_body TERM_CODE
### term_code_body: TERM_CODE
###   | term_code_body TERM_CODE

# A Constraint_Ref is a proxy for a set of constraints on an object.
constraint_ref: V_LOCAL_TERM_CODE_REF #-- e.g. "ac0003"
  {
      result = val[0]
  }

any_identifier: type_identifier
  {
      result = val[0]
  }
  | V_ATTRIBUTE_IDENTIFIER
  {
    @@logger.debug("#{__FILE__}:#{__LINE__}, V_ATTRIBUTE_IDENTIFIER = #{word} at #{@filename}")
      result = val[0]
  }


#----------------- TAKEN FROM DADL_VALIDATOR.Y -------------------
#-----------------        DO NOT MODIFY        -------------------
#---------------------- BASIC DATA VALUES -----------------------

duration_pattern: V_ISO8601_DURATION_CONSTRAINT_PATTERN
  {
    result = OpenEHR::AM::Archetype::ConstraintModel::Primitive::C_DURATION.new #val[0]
  }

end
