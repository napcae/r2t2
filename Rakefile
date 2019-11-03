#!/usr/bin/env ruby
# frozen_string_literal: true

require 'http'

SMLoadrVersion = '1.9.5'
SMLoadrLink = "https://git.fuwafuwa.moe/SMLoadrDev/SMLoadr/releases/download/v#{SMLoadrVersion}/SMLoadr-linux-x64_v#{SMLoadrVersion}.zip"
SMLoadr = 'SMLoadr-linux-x64.zip'

task :prepare do
  if !File.file?(SMLoadr)
    puts 'Downloading SMLoadr.'
    File.open(SMLoadr, 'w') do |f|
      f.write(HTTP.follow.get(SMLoadrLink))
      puts 'Downloading SMLoadr successful.'
    rescue
      File.delete(SMLoadr)
      puts 'Download failed.'
    end

  else
    puts 'SMLoadr already present.'
  end
end

task :build do
  system("unzip -f #{SMLoadr}")
  system("chmod +x SMLoadr-linux-x64")
  system('docker build -t favtrackloader:dev .')
end

task :run do
  Rake::Task['prepare'].execute
  Rake::Task['build'].execute
  system('docker run -it favtrackloader:dev')
end
