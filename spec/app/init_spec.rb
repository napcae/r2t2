require_relative '../../app/init.rb'
require_relative '../../lib/scrape.rb'
require_relative '../../lib/clean_helper.rb'

require 'HTTParty'

describe "Startup" do 
let (:s) { Startup.new.init('persistent_queue.json') }
let (:p) { JSON.parse(File.read('persistent_queue.json')) }

	context "#init" do		
		it "returns true on success" do
			expect(s).to be true
	    end
	end

	context "#persistence_file!" do
	  it "returns a hash with 50 artists/tracks" do
		  expect(p).to be_an_instance_of(Array)
    end
	end

	context "#persistence_file!" do
	  it "returns a hash with 50 artists/tracks" do
		  expect(p).to_not be_empty
    end
	end

	context "#persistence_file!" do
	  it "returns a hash with 50 artists/tracks" do
		  expect(p).to_not be_empty
    end
	end
end