queue_item = {
  "artist": "Rogue Wave",
  "track": "Aesop Rock",
  "link": "https://www.deezer.com/track/926410542",
  "jid": "7e3140788ac9ec2c708dff9d549dbed3",
  "state": "error"
}

puts "test"

download_result = `cd ./vendor/SMLoadr && ./SMLoadr-linux-x64 -u #{queue_item['link']} -p /usr/src/app/app_data/DOWNLOADS/`

download_result = Timeout::timeout(1) {
`cd ./vendor/SMLoadr && ./SMLoadr-linux-x64 -u #{queue_item['link']} -p /usr/src/app/app_data/DOWNLOADS/`
}


puts "asdasdasdas"
puts download_result 
if download_result.include? 'Finished downloading track'
  queue_item["state"] = "finished"
  logger.debug("Successfully downloaded: #{queue_item}")
else
  queue_item["state"] = "error"
  logger.debug("Error while executing SMLoadr: #{download_result}")
end