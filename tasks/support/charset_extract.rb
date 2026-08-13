# Maintenance script (invoke via `rake charset:extract`, never autoloaded):
# regenerates lib/openehr/rm/data_types/charset.lst from a local copy of
# the IANA character-sets registry
# (http://www.iana.org/assignments/character-sets).
#
# Usage: download the "character-sets" file into the current directory,
# then run this script; it writes charset.lst into the current directory.

class CharacterSets
  def self.get_list
    list = Array.new
    open('character-sets') do |file|
      while line = file.gets
        if /^((Name:)|(Alias:)) (\S+)/ =~ line
          list << $4 unless $4 == "None"
        end
      end
    end
    return list
  end
end

if $PROGRAM_NAME == __FILE__
  open('charset.lst', 'w') do |f|
    CharacterSets.get_list.each do |line|
      f.puts(line)
    end
  end
end
