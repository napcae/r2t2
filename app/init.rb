# frozen_string_literal: true

require_relative '../lib/logging.rb'
require_relative '../lib/scrape.rb'
require_relative '../lib/clean_helper.rb'
require_relative '../lib/queue_object.rb'
require 'JSON'
require 'HTTParty'

class Startup
  include Logging

  def init(persistence_file)
    if File.file?(persistence_file)
      if JSON.parse(File.read(persistence_file)).length < 50
        logger.info('persistent_queue.json has less than 50 items, going to delete and recreate..')
        File.delete(persistence_file)
        persistence_file!(persistence_file)
      end
      return true
      # puts persistent_queue = JSON.parse(File.read(persistence_file))
    else
      persistence_file!(persistence_file)
    end
    logger.info('persistent_queue.json exists')
    logger.info('Tracklist initialized...')
  end

  def persistence_file!(persistence_file)
    scraper = Scrape.new

    track = scraper.get_track_from_hypem
    artist = scraper.get_artist_from_hypem

    logger.info('persistent_queue.json not found')
    logger.info('Starting up and initializing tracklist...')

    persistent_queue = []

    (0...track.size).each do |index|
      queue = QueueObject.new
      temp_hash = queue.info(index, artist, track)

      persistent_queue << temp_hash
      File.open(persistence_file, 'w') do |f|
        f.write(persistent_queue.to_json)
      end
      logger.debug(JSON.pretty_generate(temp_hash))
    end
  end
end
