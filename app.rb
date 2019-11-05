#!/usr/bin/env ruby
# frozen_string_literal: true
require_relative "lib/scrape"
require 'nokogiri'
require 'json'
require 'pry'
require 'csv'
require 'pp'
require 'http'
require 'httparty'
require 'cgi'

require './helper.rb'

# constants and var init
DEEZER_API_ENDPOINT = 'https://api.deezer.com/search?q='
track, artist = ''


DATE = Time.new

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
  total_songs_count  = json['total']

  if total_songs_count.zero?
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

#####
# push tracks into array [link]
# have consumer reading array from bottom
#
song_list = []

scraper = Scrape.new

track = scraper.get_track
artist = scraper.get_artist

puts track.size

loop do
  (0..track.size).each do |index|
    puts "index: #{index + 1}"
    puts "Artist: #{artist[index]} - Track: #{track[index]}"
    # possible states: queued, pending(executed), failed, completed
    puts "state: queued"
    sleep 1
  end
  puts "................................WAITING................................"
  sleep 5
end
if File.file?('scraped.json')
  puts 'scraped.json exists'
  # load file
  # 
else
  puts "Starting up and get tracklist..."
  puts 'scraped.json not found'
  init
  File.open("scraped.json","w") do |f|
    f.write(song_list)
  end
end

puts "Tracklist initialized..."
# lastDownload = File.open('.lastDownload', 'w+')
# downloadLinks = File.open('downloadLinks.txt', 'w')

# downloadLinks.puts link.to_s

# `./SMLoadr-linux-x64 -u #{link}`

# puts "[#{date}]" + artist + ' - ' + track + ' sent to download.'
# lastDownload.puts link.to_s

# downloadLinks.close
# lastDownload.close
# multiple entries or nothing found for #artist - #track:
# [1] artist - track
# [2] artist - track
# [m] manual search
