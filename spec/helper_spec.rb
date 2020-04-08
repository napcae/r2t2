# frozen_string_literal: true

require 'spec_helper'
require_relative '../helper.rb'

DEEZER_API_ENDPOINT = 'https://api.deezer.com/search?q='

artist = ['',
          'lose yourself',
          'la malquerida',
          'testartist',
          '']

track = ['',
         'eminem',
         'natalia lafourcade',
         '',
         'testtrack']

describe 'QueueObject#info' do
  before(:each) do
    @queue_object = QueueObject.new
  end

  context 'given valid parameters' do
    it 'returns an hash object with link and a state for the queue' do
      expect(@queue_object.info(1, artist, track)).to include(
        'artist' => 'lose yourself',
        'track' => 'eminem',
        'link' => '',
        'jid' => 'a8407789f2310d5009c12e5c8857170a',
        'state' => 'queued'
      )
    end
  end

  context 'given empty artist/track' do
    it 'raises an error' do
      expect { @queue_object.info(0, artist, track) }.to raise_error(ArgumentError)
    end

    it 'raises an error' do
      expect { @queue_object.info(3, artist, track) }.to raise_error(ArgumentError)
    end

    it 'raises an error' do
      expect { @queue_object.info(4, artist, track) }.to raise_error(ArgumentError)
    end
  end
end
