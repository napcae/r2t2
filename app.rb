#!usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'json'
require 'csv'
require 'pp'
require 'http'
require 'logger'
require 'httparty'
Dir['./lib/*.rb'].each { |file| require file }
Dir['./app/*.rb'].each { |file| require file }

# constants and var init
DEEZER_API_ENDPOINT = 'https://api.deezer.com/search?q='
track, artist = ''
PERSISTENT_QUEUE_FILE = 'tmp/persistent_queue.json'


################################################################
# this checks whether queue.json exists to reload state after programm is aborted
################################################################
# TODO: Put this in a init function instead of main programm, start with tests
worker_queue, persistent_queue = []

if Startup.new.init(PERSISTENT_QUEUE_FILE)
  persistent_queue = JSON.parse(File.read(PERSISTENT_QUEUE_FILE))
  worker_queue = persistent_queue
end

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

semaphore = Mutex.new

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

    logger.debug("Last known song on hypem should be: #{artist[count]} - #{track[count]}")

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
      
      # mutex so shared access data is safe
      semaphore.synchronize {
        worker_queue.unshift(temp_hash)
      }

      logger.debug("Worker Queue, last 5 items: #{worker_queue[0..4].to_yaml}")
      count += 1

      semaphore.synchronize {
        logger.debug('Attempting to persist changes to disk')
        File.open(PERSISTENT_QUEUE_FILE, 'w') do |f|
          f.write(worker_queue.to_json)
        end
      }
    end
  end
end

consumer = Thread.new do
  loop do
    #@consumers.times do
    puts "going to consume main"
      queue_item = worker_queue.find { |i| i["state"] == "queued" }

      if queue_item ## as long as items with "queued" as status exists, do this:
        if queue_item["link"].empty?
          logger.debug("No Link in track to consume found.")
          queue_item["state"] = "error"
        else
          ## now go download/process
          download_result = `cd ./vendor/SMLoadr && ./SMLoadr-linux-x64 -u "#{queue_item["link"]}"`

          if download_result #
            queue_item["state"] = "finished"
            link = queue_item["link"]
            logger.debug("Successfully downloaded: #{link}")
          else
            queue_item["state"] = "error"
            logger.debug("Error while executing SMLoadr: #{download_result}")
          end
        end
      else
        logger.debug("No new items to queue found") 
        sleep 300
      end

      semaphore.synchronize {
        File.open(PERSISTENT_QUEUE_FILE, 'w') do |f|
          f.write(worker_queue.to_json)
        end
      }
    end
  end


#pc = ProducerConsumer.new(persistent_queue)
producer.join
consumer.join




# puts "run it"
# pc.run
# sleep 0.5
# pc.kill
#consumer.join

#####
# consumer: reads the queue and downloads the track
# `./SMLoadr-linux-x64 -u #{link}`

# lastDownload.close
# multiple entries or nothing found for #artist - #track:
# [1] artist - track
# [2] artist - track
# [m] manual search
