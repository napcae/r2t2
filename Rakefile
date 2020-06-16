#!/usr/bin/env ruby

require 'httparty'
require 'rspec/core/rake_task'
require 'fileutils'

# https://git.fuwafuwa.moe/SMLoadrDev/SMLoadr/src/tag/v1.20.0
SMLoadrLink = "https://git.fuwafuwa.moe/attachments/9a051535-b6d7-44ae-bee2-bb9aef22e189"
SMLoadr = 'vendor/SMLoadr/SMLoadr-linux-x64-v1.20.0.zip'

RSpec::Core::RakeTask.new(:spec)
task default: :spec

task :prepare do
  if !File.file?(SMLoadr)
    FileUtils.mkdir_p 'vendor/SMLoadr'
    puts 'Downloading SMLoadr.'
    File.open(SMLoadr, 'w') do |f|
      f.write(HTTParty.get(SMLoadrLink))
      puts 'Downloading SMLoadr successful.'
    rescue StandardError
       File.delete(SMLoadr)
       puts 'Download failed.'
       puts HTTParty.get(SMLoadrLink).response
    end

  else
    puts 'SMLoadr already present.'
  end
end

task :build do
  system("unzip -u #{SMLoadr} -d vendor/SMLoadr/")
  system('chmod +x vendor/SMLoadr/SMLoadr-linux-x64')
  system('docker build -t favtrackloader:dev .')
end

task :run do
  Rake::Task['prepare'].execute
  Rake::Task['build'].execute
  system('docker run -it favtrackloader:dev')
end
