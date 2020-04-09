this programm scrapes https://hypem.com/napcae to write a list for smloadr to download favorited/loved tracks in the background

## todo
* add proxies to avoid rate limit
* handle errors in scraping(emtpy response), e.g.: "D, [2020-04-07T14:42:30.907497 #34365] DEBUG -- : Worker queue: [{"artist"=>"", "track"=>"", "link"=>"", "jid"=>"d41d8cd98f00b204e9800998ecf8427e", :state=>"queued"}]": write test
* save persistent file on interrupt
* what happens if songs are removed from fav tracks? write test
* tests
* should accept input via telegram/cli
* soundcloud as input
* youtube as input

* persistent_queue.json is going to get bigger over time this programm runs, worry about that


## works so far:

* persistence over restart
* producer which adds new songs to working queue

## missing:
consumer to download tracks


Reference: https://blog.hartleybrody.com/web-scraping-cheat-sheet/#using-proxy-servers