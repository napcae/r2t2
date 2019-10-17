require 'HTTParty'
require 'Nokogiri'
require 'json'
require 'pry'
require 'csv'
require 'pp'

#helper
def suppress_output
  original_stdout, original_stderr = $stdout.clone, $stderr.clone
  $stderr.reopen File.new('/dev/null', 'w')
  $stdout.reopen File.new('/dev/null', 'w')
  yield
ensure
  $stdout.reopen original_stdout
  $stderr.reopen original_stderr
end
#######

# constants
HYPEM_TEXT=" - search Hype Machine for this artist"
__DEEZER_API_ENDPOINT="https://api.deezer.com/search?q="
track, artist = ""

#parsed_page = HTTParty.get("https://hypem.com/napcae")
parsed_page = File.open("index.html")
hypem_loved = Nokogiri::HTML(parsed_page)

# parse loved songs from hypem loved page
hypem_loved.css('#track-list').css('.track_name').map do | track_item |
  suppress_output {
  artist = track_item.css(".artist").attribute('title').text
  
  puts artist = artist.gsub(HYPEM_TEXT,"")

  track = track_item.css(".base-title").text

  puts track = track.gsub(/ \(.+\)/,"")

  puts "###################################"
  }
end

# creating api call for deezer, search for artist and tracks scraped from hypem loved page
# TODO: Replace with actual variables from step above
query = __DEEZER_API_ENDPOINT + "artist:" + "\"eminem\"" + "track:" + "\"lose yourself\"" + "&limit=5&order=RANKING"

hypem = HTTParty.get(query).to_s

parsed = JSON.parse(hypem)

parsed = parsed["data"]

parsed.each do | results |
	puts results["link"]
	puts #####
end

# multiple entries or nothing found for #artist - #track:
# [1] artist - track
# [2] artist - track
# [m] manual search

