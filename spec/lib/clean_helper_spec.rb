require_relative '../../lib/clean_helper.rb'

describe 'CleanHelper#artist_track' do
  let (:c) { CleanHelper.new }
  
  context 'given an item with "(feat. OtherArtist)" in name' do
  	let (:actual) { 'Artist - SongTrack (feat. OtherArtist)' }
    let (:expected) { 'Artist - SongTrack' }

  	it 'returns input without parasenthesis' do
   	  expect(c.artist_track(actual)).to eq(expected)
    end
  end

  context 'given an item with "&" in name' do
  	let (:actual) { 'Artist & Second Artist - SongTrack' }
  	let (:expected) { 'Artist, Second Artist - SongTrack' }

  	it 'returns input without "(feat. OtherArtist)"' do
   	  expect(c.artist_track(actual)).to eq(expected)
    end
  end
  
  context 'given an item' do
  	let (:actual) { 'Artist & Second Artist - SongTrack - search Hype Machine for this artist' }
  	let (:expected) { 'Artist, Second Artist - SongTrack' }

  	it 'returns input without hypem added suffix' do
   	  expect(c.artist_track(actual)).to eq(expected)
    end
  end

  context 'given an item with "feat." or "Feat" in name' do
  	let (:actual) { 'Artist - SongTrack feat. Second Artist' }
  	let (:expected) { 'Artist - SongTrack' }

  	it 'returns clean input' do
   	  expect(c.artist_track(actual)).to eq(expected)
    end
  end

  context 'given an item with "X" or "x" in name' do
  	let (:actual) { 'Artist X Second Artist - SongTrack - search Hype Machine for this artist' }
		let (:expected) { 'Artist, Second Artist - SongTrack' }

  	it 'returns input without hypem added suffix' do
   	  expect(c.artist_track(actual)).to eq(expected)
    end
  end
end
