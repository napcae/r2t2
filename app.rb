#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/scrape'
require 'nokogiri'
require 'json'
require 'csv'
require 'pp'
require 'http'
require 'httparty'
require './helper.rb'

# constants and var init
DEEZER_API_ENDPOINT = 'https://api.deezer.com/search?q='
track, artist = ''
APP_DIR = 'tmp/persistent_queue.json'

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

################################################################
# this checks whether queue.json exists to reload state after programm is aborted
################################################################
# TODO: Put this in a init function instead of main programm, start with tests
worker_queue = []
if File.file?(APP_DIR)
  logger.info('persistent_queue.json exists')
  persistent_queue = JSON.parse(File.read(APP_DIR))
else
  scraper = Scrape.new

  track = scraper.get_track_from_hypem
  artist = scraper.get_artist_from_hypem

  # build_tracklist_to_download
  logger.info('persistent_queue.json not found')
  logger.info('Starting up and initializing tracklist...')

  persistent_queue = []

  (0...track.size).each do |index|
    queue = QueueObject.new
    temp_hash = queue.info(index, artist, track)

    persistent_queue << temp_hash
    File.open(APP_DIR, 'w') do |f|
      f.write(persistent_queue.to_json)
    end
    logger.debug(JSON.pretty_generate(temp_hash))
  end
end
worker_queue = persistent_queue
logger.info('Tracklist initialized...')

#### main program starts here
# producer: should create queue.json which holds json representation of hypem.com/napcae + deezer links
#
producer = Thread.new do
  count = 0
  loop do
    scraper = Scrape.new
    track = scraper.get_track_from_hypem
    artist = scraper.get_artist_from_hypem
    h = Digest::MD5.new

    logger.debug("Most recent song on hypem should be: #{artist[count]} - #{track[count]}")

    scraped_track_jid = h.hexdigest (artist[count]).to_s + (track[count]).to_s
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

      queue = QueueObject.new
      temp_hash = queue.info(count, artist, track)

      logger.debug("Putting job in worker queue: #{temp_hash}")
      worker_queue.unshift(temp_hash)

      logger.debug("Worker queue, last 10 items: #{worker_queue[0..9]}")

      logger.debug("Worker Queue: #{persistent_queue[0..3].to_yaml}")
      count += 1

      logger.debug('Attempting to persist changes to disk')
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

#####
# consumer: reads the queue and downloads the track
# `./SMLoadr-linux-x64 -u #{link}`


# lastDownload.close
# multiple entries or nothing found for #artist - #track:
# [1] artist - track
# [2] artist - track
# [m] manual search
