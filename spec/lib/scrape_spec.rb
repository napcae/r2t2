require_relative '../../lib/scrape.rb'
require_relative '../../lib/clean_helper.rb'
require 'HTTParty'

describe "Scrape" do
	context "#get_artist_from_hypem", :vcr do
		let (:s) { Scrape.new.get_artist_from_hypem }
		
		it "returns an array of artists" do
			expect(s).to be_an_instance_of(Array)
	  end
	end

	context "#get_artist_from_hypem", :vcr do
		let (:s) { Scrape.new.get_track_from_hypem }
		
		it "returns an array of tracks" do
			expect(s).to be_an_instance_of(Array)
	  end
  end
end