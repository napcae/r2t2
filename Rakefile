#!/usr/bin/env ruby

SMLoadrVersion = '1.9.5'
SMLoadr = "https://git.fuwafuwa.moe/SMLoadrDev/SMLoadr/releases/download/v#{SMLoadrVersion}/SMLoadr-linux-x86_v#{SMLoadrVersion}.zip"
require 'http'

task :prepare do
  if !File.file?("SMLoadr-linux-x86.zip")
  	puts "Downloading SMLoadr."
  	File.open("SMLoadr-linux-x86.zip", "w") { |f|
 		f.write(HTTP.follow.get(SMLoadr))
  	}
  	puts "Downloading SMLoadr successful."
  else
  	puts "SMLoadr already present."
  end
end

task :run do
  