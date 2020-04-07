#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/scrape'
require 'nokogiri'
require 'json'
require 'csv'
require 'pp'
require 'http'
require 'httparty'
require 'cgi'

require './helper.rb'

# constants and var init
DEEZER_API_ENDPOINT = 'https://api.deezer.com/search?q='
track, artist = ''
APP_DIR = 'tmp/persistent_queue.json'

DATE = Time.new
logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

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

scraper = Scrape.new

track = scraper.get_track
artist = scraper.get_artist

################################################################
# this checks whether queue.json exists to reload state after programm is aborted
################################################################
worker_queue = []
if File.file?(APP_DIR)
  logger.info('persistent_queue.json exists')
  persistent_queue = JSON.parse(File.read(APP_DIR))
  worker_queue = persistent_queue
else
  # build_tracklist_to_download
  logger.info('persistent_queue.json not found')
  logger.info('Starting up and initializing tracklist...')

  persistent_queue = []

  (0...track.size).each do |index|
    link = get_track_link((artist[index]).to_s, (track[index]).to_s)
    jid = Digest::MD5.hexdigest (artist[index]).to_s + (track[index]).to_s
    temp_hash = {
      "index": index.to_s,
      "artist": (artist[index]).to_s,
      "track": (track[index]).to_s,
      "link": (link[0]).to_s,
      "jid": jid.to_s,
      ## possible states: queued, pending(to be processed by consumer), failed, completed
      "state": 'queued'
    }

    persistent_queue << temp_hash
    File.open(APP_DIR, 'w') do |f|
      f.write(persistent_queue.to_json)
    end
    logger.debug(JSON.pretty_generate(temp_hash))
    # sleep 1
    # calculate hash and write to `DownloadedOrQueuedQueue`
    # if already downloaded, don't enqueue
    # otherwise put in queue
  end
end

logger.info('Tracklist initialized...')

# while true do
#   scraper = Scrape.new
#   track = scraper.get_track
#   artist = scraper.get_artist
#   logger.debug("Freshest: #{artist[0]} - #{track[0]}")
#   sleep 5
# end

#### main program starts here
# producer: should create queue.json which holds json representation of hypem.com/napcae + deezer links
# save highest queued/pending job as .lastDownloaded
#

producer = Thread.new do
  count = 0
  loop do
    scraper = Scrape.new
    track = scraper.get_track
    artist = scraper.get_artist

    logger.debug("Most recent song on hypem should be: #{artist[count]} - #{track[count]}")
    scraped_track_jid = Digest::MD5.hexdigest (artist[count]).to_s + (track[count]).to_s
    # check if hash of new song is already known
    scraped_track_of_persistent_queue = persistent_queue.find { |x| x['jid'] == scraped_track_jid }

    # if favorite from hypem is already in persistence file, don't add to queue, otherwise add new songs
    if scraped_track_of_persistent_queue
      logger.info('No new songs found...')
      logger.debug("most recent song in persistent_queue: #{worker_queue[0]}")
      count = 0
      sleep 300
    else
      logger.debug("New items found! Going to queue: #{artist[count]} - #{track[count]}")

      link = get_track_link((artist[count]).to_s, (track[count]).to_s)
      jid = Digest::MD5.hexdigest (artist[count]).to_s + (track[count]).to_s
      
      temp_hash = {
        'artist' => (artist[count]).to_s,
        'track' => (track[count]).to_s,
        'link' => (link[0]).to_s,
        'jid' => jid.to_s,
        ## possible states: queued, pending(to be processed by  consumer), failed, completed
        'state' => 'queued'
      }

      logger.debug("Putting job in worker queue: #{temp_hash}")
      worker_queue.unshift(temp_hash)

      logger.debug("Worker queue, last 10 items: #{worker_queue[0..9]}")

      logger.debug("Worker Queue: #{persistent_queue[0..3].to_yaml}")
      count += 1

      logger.debug("Attempting to persist changes to disk")
      File.open(APP_DIR, 'w') do |f|
       f.write(persistent_queue.to_json)
      end
    end
  end
end

# consumer = Thread.new do
#   loop do
#     puts "I'm here"
#     sleep 5
#   end
# end

producer.join
# consumer.join
# consumer: reads the queue and downloads the track

### notes:
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
