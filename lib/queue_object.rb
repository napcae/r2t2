## creating hashes
class QueueObject
  DEEZER_API_ENDPOINT = 'https://api.deezer.com/search?q='
  # creating api call for deezer, search for artist and tracks scraped from hypem loved page
  # return deezer link for smloadr
  ###
  # receives input; artist: name of artist to search for, track: name of track to search for,
  # title_count: number of tracks to return if there are multiple results
  #
  # function returns link, status code as array
  ###
  def self.get_track_link(artist, track, title_count = 1)
    html_escape = CGI.escape('artist:' + "\"#{artist}\"" + 'track:' + "\"#{track}\"" + "&limit=#{title_count}&order=RANKING")
    query = DEEZER_API_ENDPOINT + html_escape

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

  ##  
  # given input of an index(of artist/track list), 
  # a list of artists and tracks
  # 
  # will return hash with artist name, track name, link to deezer,
  # hashed jobID and a state
  def info(index = 0, artist_list, track_list)
    state = 'queued'

    if artist_list[index].empty? || track_list[index].empty?
      raise ArgumentError, 'Artist or Track missing!'
    end

    # if artist_list[index] == nil
    link = QueueObject.get_track_link((artist_list[index]).to_s, (track_list[index]).to_s)
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

  def info!
  end
end
