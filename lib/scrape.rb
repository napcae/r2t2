# frozen_string_literal: true

class Scrape
  def initialize
    @parsed_page = HTTParty.get('https://hypem.com/napcae')
    @hypem_loved = Nokogiri::HTML(@parsed_page)
  end

  def get_artist_from_hypem
    # parse loved songs from hypem loved page
    @hypem_loved.css('#track-list').css('.track_name').map do |track_item|
      artist = clean_string(track_item.css('.artist').attribute('title').text)
    end
  end

  def get_track_from_hypem
    # parse loved songs from hypem loved page
    @hypem_loved.css('#track-list').css('.track_name').map do |track_item|
      track = clean_string(track_item.css('.base-title').text)
    end
  end
end
