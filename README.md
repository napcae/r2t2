this programm scrapes https://hypem.com/napcae to write a list for smloadr to download favorited/loved tracks in the background

## todo
* add proxies to avoid rate limit
* handle errors in scraping(emtpy response), e.g.: "D, [2020-04-07T14:42:30.907497 #34365] DEBUG -- : Worker queue: [{"artist"=>"", "track"=>"", "link"=>"", "jid"=>"d41d8cd98f00b204e9800998ecf8427e", :state=>"queued"}]": write test
* save persistent file on interrupt - done
* what happens if songs are removed from fav tracks? write test
* should accept input via telegram/cli
* soundcloud as input
* youtube as input
* graceful interrupt(ctrl+c)

* persistent_queue.json is going to get bigger over time this programm runs, worry about that


## works so far:

* persistence over restart
* producer which adds new songs to working queue

## missing:
* producer
	* change state of songs when link is not found
		* or use a different download handler(soundcloud/bandcamp/youtube)
* consumer to download tracks
	* check queue for new items from the bottom
		* if item with state queue found
			* attempt to download it 
				* if fail, add retry with backoff
		* then write new state to persistent file
	* repeat

* bug? changing persistent_file.json on disk won't do anything since program is loading this file only once at start. any edit will be overwritten by the working queue in memory
* retry + error code of system execution(smloadr) is needed

* push message if need tracks are available
* error handling to sentry:  Honeybadger, Airbrake, Rollbar, BugSnag, Sentry, Exceptiontrap, Raygu
* https://blog.hartleybrody.com/web-scraping-cheat-sheet/#using-proxy-servers
