# frozen_string_literal: true

require 'cgi'
require 'http'

HYPEM_ADDED_SUFFIX = ' - search Hype Machine for this artist'

def clean_string(str)
  # remove until artist: "SB : COEO"
  str = str.gsub(/.+\:\s/, '')

  # remove everything in paranthesis, i.e.: "artist - SongTrack (feat. xxxx)"
  str = str.gsub(/ \(.+\)/, '')

  # remove '&'(they mess up deezer search = no results)
  str = str.gsub(/\s&/, ',')

  # remove hypem added bullshit
  str = str.gsub(HYPEM_ADDED_SUFFIX, '')

  # remove "feat". or "Feat.", e.g. "Artist feat. artist2 - song"
  str = str.gsub(/ ([f|F]eat.*)/, '')

  # remove Artist X Artist, e.g. "Artist X Artist2 - song" Calper x Son of Cabe
  str = str.gsub(/ [xX] /, ', ')
end

# puts clean_string("SB : COEO rubyartist (feat. deine mutter) + test (feat. deine mutter) - search Hype Machine for this artist")
