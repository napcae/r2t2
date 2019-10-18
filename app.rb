#!/usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'json'
require 'pry'
require 'csv'
require 'pp'
require 'http'
require 'cgi'

require './helper.rb'

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

  json = JSON.parse(deezer_query)
  parsed = json['data']
  total  = json['total']

  if total.zero?
    debug = artist + ' - ' + track
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

# parse loved songs from hypem loved page
hypem_loved.css('#track-list').css('.track_name').map do |track_item|
  artist = track_item.css('.artist').attribute('title').text.gsub(HYPEM_TEXT, '')
  track = track_item.css('.base-title').text.gsub(/ \(.+\)/, '')

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
