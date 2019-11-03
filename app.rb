#!/usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'json'
require 'pry'
require 'csv'
require 'pp'
require 'http'
require 'HTTParty'
require 'cgi'

require './helper.rb'

# constants and var init
DEEZER_API_ENDPOINT = 'https://api.deezer.com/search?q='
track, artist = ''

parsed_page = HTTParty.get('https://hypem.com/napcae')
# parsed_page = File.open('index.html')

hypem_loved = Nokogiri::HTML(parsed_page)

date = Time.new

# creating api call for deezer, search for artist and tracks scraped from hypem loved page
# return deezer link for smloadr
###
# function returns link, status code as array
###
def get_track_link(artist, track, title_count = 1)
  escape = CGI.escape('artist:' + "\"#{artist}\"" + 'track:' + "\"#{track}\"" + "&limit=#{title_count}&order=RANKING")
  query = DEEZER_API_ENDPOINT + escape

  deezer_query = HTTP.get(query).to_s

  json = JSON.parse(deezer_query)
  parsed = json['data']
  total  = json['total']

  if total.zero?
    ['', false]
  else
    parsed.take(title_count).each do |deezer_search_response|
      link = deezer_search_response['link']
      title = deezer_search_response['title']
      artist_name = deezer_search_response['artist']['name']
      album_name =  deezer_search_response['album']['title']

      return [link, true]
    end
  end
end

# parse loved songs from hypem loved page
hypem_loved.css('#track-list').css('.track_name').reverse.map do |track_item|
  artist = clean_string(track_item.css('.artist').attribute('title').text)
  track = clean_string(track_item.css('.base-title').text)

  # puts "Info " + artist + ": " + track
  link, state = get_track_link(artist, track)
  if !state
    puts "[#{date}]" + artist + ' - ' + track + ' not found.'
  else
    lastDownload = File.open('.lastDownload', 'w+')
    downloadLinks = File.open('downloadLinks.txt', 'w')

    downloadLinks.puts link.to_s

#    puts system("./SMLoadr-linux-x86")

    puts "[#{date}]" + artist + ' - ' + track + ' sent to download.'
    lastDownload.puts link.to_s

    downloadLinks.close
    lastDownload.close
  end
  # puts get_track_link("eminem","lose yourself")[1]
end

# multiple entries or nothing found for #artist - #track:
# [1] artist - track
# [2] artist - track
# [m] manual search
