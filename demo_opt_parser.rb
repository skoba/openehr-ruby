#!/usr/bin/env ruby

require_relative 'lib/openehr'

# OPT parser demo
puts "OpenEHR OPT Parser Demo"
puts "=" * 50

# Parse minimum template
puts "\n1. Parsing minimum_template.opt:"
minimum_opt_file = 'spec/lib/openehr/opt_parser/minimum_template.opt'
parser = OpenEHR::Parser::OPTParser.new(minimum_opt_file)
template = parser.parse

puts "Template ID: #{template.template_id.value}"
puts "Concept: #{template.concept}"
puts "Language: #{template.language.code_string}"
puts "UID: #{template.uid.value}"

puts "\nDefinition:"
puts "  RM Type: #{template.definition.rm_type_name}"
puts "  Node ID: #{template.definition.node_id}"
puts "  Path: #{template.definition.path}"
puts "  Archetype ID: #{template.definition.archetype_id.value}"
puts "  Attributes: #{template.definition.attributes.size}"

template.definition.attributes.each_with_index do |attr, i|
  puts "    #{i+1}. #{attr.rm_attribute_name} (#{attr.class.name.split('::').last})"
end

puts "\nComponent Terminologies:"
template.component_terminologies.each do |archetype_id, terminology|
  puts "  #{archetype_id}: #{terminology.term_definitions.size} languages"
  terminology.term_definitions.each do |lang, terms|
    puts "    #{lang}: #{terms.size} terms"
  end
end

# Parse eReferral template
puts "\n\n2. Parsing eReferral.opt:"
ereferral_opt_file = 'spec/lib/openehr/opt_parser/eReferral.opt'
parser2 = OpenEHR::Parser::OPTParser.new(ereferral_opt_file)
template2 = parser2.parse

puts "Template ID: #{template2.template_id.value}"
puts "Concept: #{template2.concept}"
puts "Language: #{template2.language.code_string}"
puts "UID: #{template2.uid.value}"

puts "\nDefinition:"
puts "  RM Type: #{template2.definition.rm_type_name}"
puts "  Node ID: #{template2.definition.node_id}"
puts "  Path: #{template2.definition.path}"
puts "  Archetype ID: #{template2.definition.archetype_id.value}"
puts "  Attributes: #{template2.definition.attributes.size}"

puts "\nDemo completed successfully!"
puts "OPT parser can successfully create Template instances from .opt files."