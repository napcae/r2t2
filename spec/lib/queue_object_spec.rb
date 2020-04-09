require_relative '../../lib/queue_object.rb'

artist = ['eminem',
          '',
          'testartist',
          '']

track = ['lose yourself',
         '',
         '',
         'testtrack']

describe 'QueueObject#info' do
  # before(:each) do
  #   @queue_object = QueueObject.new
  # end

  let (:queue_object) { QueueObject.new }

  context 'given valid parameters', :vcr do
    it 'returns an hash object with link and a state for the queue' do
      expect(queue_object.info(0, artist, track)).to include(
        'artist' => 'eminem',
        'track' => 'lose yourself',
        'link' => 'https://www.deezer.com/track/1109731',
        'jid' => '1217912a7c78a07a26a317beb481b78b',
        'state' => 'queued'
      )
    end
  end

  context 'given empty artist + track' do
    it 'raises an error' do
      expect { queue_object.info(1, artist, track) }.to raise_error(ArgumentError)
    end
  end

  context 'given empty track' do
    it 'raises an error' do
      expect { queue_object.info(2, artist, track) }.to raise_error(ArgumentError)
    end
  end
  
  context 'given empty artist' do
    it 'raises an error' do
      expect { queue_object.info(3, artist, track) }.to raise_error(ArgumentError)
    end
  end
end
