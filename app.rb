# frozen_string_literal: true

require 'nokogiri'
require 'json'
require 'pry'
require 'csv'
require 'pp'
require 'http'
require 'cgi'

# helper
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
#######

# constants and var init
HYPEM_TEXT = ' - search Hype Machine for this artist'
track, artist = ''

# parsed_page = HTTParty.get("https://hypem.com/napcae")
parsed_page = File.open('index.html')
hypem_loved = Nokogiri::HTML(parsed_page)

def get_track_info(artist, track, title_count = 1, *_args)
  __DEEZER_API_ENDPOINT = 'https://api.deezer.com/search?q='
  # creating api call for deezer, search for artist and tracks scraped from hypem loved page
  # TODO: Replace with actual variables from step above
  escape = CGI::escape('artist:' + "\"#{artist}\"" + 'track:' + "\"#{track}\"" + "&limit=#{title_count}&order=RANKING")
  query = __DEEZER_API_ENDPOINT + escape

  deezer_query = HTTP.get(query)

  parsed = JSON.parse(deezer_query)
  parsed = parsed['data']

  parsed.take(title_count).each do |deezer_search_response|
    link = deezer_search_response['link']
    title = deezer_search_response['title']
    artist_name = deezer_search_response['artist']['name']
    album_name =  deezer_search_response['album']['title']

    # for debugging
    debug = '# ' + artist_name + ' - ' + title + ' from ' + album_name

    return [link, debug]
  end
end

# puts get_track_info("eminem","lose yourself")[0]

# parse loved songs from hypem loved page
hypem_loved.css('#track-list').css('.track_name').map do |track_item|
  suppress_output do
    artist = track_item.css('.artist').attribute('title').text
    artist = artist.gsub(HYPEM_TEXT, '')

    track = track_item.css('.base-title').text
    track = track.gsub(/ \(.+\)/, '')

    puts artist + ' - ' + track
    puts '###################################'
  end

  puts artist + ' - ' + track

  # puts "Info " + artist
  puts get_track_info(artist, track)[0]
  # puts get_track_info("eminem","lose yourself")[1]
end

# multiple entries or nothing found for #artist - #track:
# [1] artist - track
# [2] artist - track
# [m] manual search
