class Scrape
  def initialize
    @parsed_page = HTTParty.get("https://hypem.com/napcae")
    @hypem_loved = Nokogiri::HTML(@parsed_page)
  end

  def get_artist 
    # parse loved songs from hypem loved page
    @hypem_loved.css('#track-list').css('.track_name').reverse.map do |track_item|
      artist = clean_string(track_item.css('.artist').attribute('title').text)
    end
  end

  def get_track 
    # parse loved songs from hypem loved page
    @hypem_loved.css('#track-list').css('.track_name').reverse.map do |track_item|
      track = clean_string(track_item.css('.base-title').text)
    end
  end
end

def worker
  link, state = get_track_link(artist, track)
  if !state
    puts "[#{DATE}]" + "\"" + artist + ' - ' + track + "\" not found."
  else
    # push into array
    a = song_list.push(link)
  end
end