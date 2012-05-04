#! /usr/bin/env ruby
# charactor sets extraction from download file from
# http://www.iana.org/assignments/character-sets
# as character-sets

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

open('charset.lst','w') do |f|
  CharacterSets.get_list.each do |line|
    f.puts(line)
  end
end
