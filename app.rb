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
APP_DIR = 'tmp/queue.json'

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

scraper = Scrape.new

track = scraper.get_track
artist = scraper.get_artist

################################################################
# this checks whether queue.json exists to reload state after programm is aborted
################################################################

if File.file?(APP_DIR)
  puts 'queue.json exists'

  ## main queue loop
  # load file into memory to work with
  # 

else
  #build_tracklist_to_download
  puts 'queue.json not found'
  puts "Starting up and initializing tracklist..."
  
  temp_hash = {}
  fin_hash = []

  (0...track.size).each do |index|
    link = get_track_link("#{artist[index]}", "#{track[index]}")
    temp_hash = {
      "index": "#{index}",
      "Artist": "#{artist[index]}",
      "Track:": "#{track[index]}",
      "link": "#{link[0]}",
    ## possible states: queued, pending(executed), failed, completed
      "state": "queued"
    }

    fin_hash << temp_hash
    File.open(APP_DIR, "w") do |f|
      f.write(fin_hash.to_json)
    end
    puts JSON.pretty_generate(temp_hash)
    #sleep 1
    # calculate hash and write to `DownloadedOrQueuedQueue`
    # if already downloaded, don't enqueue
    # otherwise put in queue
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
