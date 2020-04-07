# frozen_string_literal: true

HYPEM_TEXT = ' - search Hype Machine for this artist'

def suppress_output
  original_stdout = $stdout.clone
  original_stderr = $stderr.clone
  $stderr.reopen File.new('/dev/null', 'w')
  $stdout.reopen File.new('/dev/null', 'w')
  yield
ensure
  $stdout.reopen original_stdout
  $stderr.reopen original_stderr
end

def clean_string(str)
  # remove until artist: "SB : COEO"
  str = str.gsub(/.+\:\s/, '')

  # remove everything in paranthesis, i.e.: "artist - SongTrack (feat. xxxx)"
  str = str.gsub(/ \(.+\)/, '')

  # remove '&'(they mess up deezer search = no results)
  str = str.gsub(/\s&/, ',')

  # remove hypem added bullshit
  str = str.gsub(HYPEM_TEXT, '')

  # remove "feat". or "Feat.", e.g. "Artist feat. artist2 - song"
  str = str.gsub(/ ([f|F]eat.*)/, '')

  # remove Artist X Artist, e.g. "Artist X Artist2 - song"
  str = str.gsub(/ X /, ', ')
end

# puts clean_string("SB : COEO rubyartist (feat. deine mutter) + test (feat. deine mutter) - search Hype Machine for this artist")
