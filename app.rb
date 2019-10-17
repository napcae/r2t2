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
DEEZER_API_ENDPOINT = 'https://api.deezer.com/search?q='
HYPEM_TEXT = ' - search Hype Machine for this artist'
track, artist = ''

# parsed_page = HTTParty.get("https://hypem.com/napcae")
parsed_page = File.open('index.html')
hypem_loved = Nokogiri::HTML(parsed_page)

# creating api call for deezer, search for artist and tracks scraped from hypem loved page
def get_track_info(artist, track, title_count = 1)
  escape = CGI.escape('artist:' + "\"#{artist}\"" + 'track:' + "\"#{track}\"" + "&limit=#{title_count}&order=RANKING")
  query = DEEZER_API_ENDPOINT + escape

  deezer_query = HTTP.get(query).to_s
  # debug offline
  # deezer_query = '{"data":[{"id":747809562,"readable":true,"title":"Zeitgeist (feat. Bastien)","title_short":"Zeitgeist (feat. Bastien)","title_version":"","link":"https:\/\/www.deezer.com\/track\/747809562","duration":304,"rank":66909,"explicit_lyrics":false,"explicit_content_lyrics":0,"explicit_content_cover":2,"preview":"https:\/\/cdns-preview-4.dzcdn.net\/stream\/c-43e103d556039858d9d65b4b654ade7a-5.mp3","artist":{"id":69374552,"name":"Calcou","link":"https:\/\/www.deezer.com\/artist\/69374552","picture":"https:\/\/api.deezer.com\/artist\/69374552\/image","picture_small":"https:\/\/cdns-images.dzcdn.net\/images\/artist\/\/56x56-000000-80-0-0.jpg","picture_medium":"https:\/\/cdns-images.dzcdn.net\/images\/artist\/\/250x250-000000-80-0-0.jpg","picture_big":"https:\/\/cdns-images.dzcdn.net\/images\/artist\/\/500x500-000000-80-0-0.jpg","picture_xl":"https:\/\/cdns-images.dzcdn.net\/images\/artist\/\/1000x1000-000000-80-0-0.jpg","tracklist":"https:\/\/api.deezer.com\/artist\/69374552\/top?limit=50","type":"artist"},"album":{"id":110124032,"title":"Zeitgeist (feat. Bastien)","cover":"https:\/\/api.deezer.com\/album\/110124032\/image","cover_small":"https:\/\/cdns-images.dzcdn.net\/images\/cover\/f3fc6d2e38c161feec09f56d92cb21ca\/56x56-000000-80-0-0.jpg","cover_medium":"https:\/\/cdns-images.dzcdn.net\/images\/cover\/f3fc6d2e38c161feec09f56d92cb21ca\/250x250-000000-80-0-0.jpg","cover_big":"https:\/\/cdns-images.dzcdn.net\/images\/cover\/f3fc6d2e38c161feec09f56d92cb21ca\/500x500-000000-80-0-0.jpg","cover_xl":"https:\/\/cdns-images.dzcdn.net\/images\/cover\/f3fc6d2e38c161feec09f56d92cb21ca\/1000x1000-000000-80-0-0.jpg","tracklist":"https:\/\/api.deezer.com\/album\/110124032\/tracks","type":"album"},"type":"track"}],"total":1}'
  # deezer_query = '{"data":[]}'
  ########

  json = JSON.parse(deezer_query)
  parsed = json['data']
  total  = json['total']

  if total.zero?
    debug = artist + ' - ' + track + ' not found.'
    ['', debug]
  else

    parsed.take(title_count).each do |deezer_search_response|
      link = deezer_search_response['link']
      title = deezer_search_response['title']
      artist_name = deezer_search_response['artist']['name']
      album_name =  deezer_search_response['album']['title']

      # for debugging
      debug = '# ' + artist_name + ' - ' + title + ' from ' + album_name
      # debug = "test"
      return [link, debug]
    end
  end
end

# link,debug = get_track_info("eminem","lose yourself")

# puts debug
# puts link

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

  # puts artist + ' - ' + track

  # puts "Info " + artist + ": " + track
  link, debug = get_track_info(artist, track)
  puts 'DEBUG: ' + debug.to_s
  puts 'LINK: ' + link.to_s
  # puts get_track_info("eminem","lose yourself")[1]
end

# multiple entries or nothing found for #artist - #track:
# [1] artist - track
# [2] artist - track
# [m] manual search
