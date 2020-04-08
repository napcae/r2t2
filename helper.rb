# frozen_string_literal: true

require 'cgi'
require 'http'

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

# creating api call for deezer, search for artist and tracks scraped from hypem loved page
# return deezer link for smloadr
###
# receives input; artist: name of artist to search for, track: name of track to search for,
# title_count: number of tracks to return if there are multiple results
#
# function returns link, status code as array
###
def get_track_link(artist, track, title_count = 1)
  escape = CGI.escape('artist:' + "\"#{artist}\"" + 'track:' + "\"#{track}\"" + "&limit=#{title_count}&order=RANKING")
  query = DEEZER_API_ENDPOINT + escape

  deezer_query = HTTP.get(query).to_s

  json = JSON.parse(deezer_query)
  parsed = json['data']
  total_songs_count = json['total']

  if total_songs_count.zero?
    ['', false]
  else
    parsed.take(title_count).each do |deezer_search_response|
      link = deezer_search_response['link']
      title = deezer_search_response['title']
      artist_name = deezer_search_response['artist']['name']
      album_name =  deezer_search_response['album']['title']

      return [link, true, title, artist_name, album_name]
    end
  end
end

## creating hashes
class QueueObject
  def create_hash(index = 0, artist_list, track_list)
    state = 'queued'

    if artist_list[index].empty? || track_list[index].empty?
      raise ArgumentError, 'Artist or Track missing!'
    end

    # if artist_list[index] == nil
    link = get_track_link((artist_list[index]).to_s, (track_list[index]).to_s)
    jid = Digest::MD5.hexdigest (artist_list[index]).to_s + (track_list[index]).to_s

    temp_hash = {
      'artist' => (artist_list[index]).to_s,
      'track' => (track_list[index]).to_s,
      'link' => (link[0]).to_s,
      'jid' => jid.to_s,
      ## possible states: queued, pending(to be processed by  consumer), failed, completed
      'state' => state.to_s
    }
  end
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
