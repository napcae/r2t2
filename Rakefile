#!/usr/bin/env ruby
# frozen_string_literal: true

require 'http'

SMLoadrVersion = '1.9.5'
SMLoadrLink = "https://git.fuwafuwa.moe/SMLoadrDev/SMLoadr/releases/download/v#{SMLoadrVersion}/SMLoadr-linux-x86_v#{SMLoadrVersion}.zip"
SMLoadr = 'SMLoadr-linux-x86.zip'

task :prepare do
  if !File.file?(SMLoadr)
    puts 'Downloading SMLoadr.'
    File.open(SMLoadr, 'w') do |f|
      f.write(HTTP.follow.get(SMLoadr))
    end
    puts 'Downloading SMLoadr successful.'
  else
    puts 'SMLoadr already present.'
  end
end

task :build do
  system("unzip -f #{SMLoadr}")
  system('docker build -t favtrackloader:dev .')
end

task :run do
  Rake::Task['prepare'].execute
  Rake::Task['build'].execute
  system('docker run -it favtrackloader:dev')
end
