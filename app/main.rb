require 'json'

class ProducerConsumer
	def initialize(queue)
		@queue = queue
		@threads = []
	end

	# def self.class_method_name
		
	# end
	def run
	  consumers
	end

  def consumers
  	puts "test consuming"
    #@consumers.times do
    @threads << Thread.new do
    	count = @queue.length

    	queue_item = @queue.find { |i| i["state"] == "queued" }

    	puts queue_item.class

			puts "queue item is: #{queue_item}"

			if queue_item # as long as items with "queued" exists, do this:
				#execute from different dir??
				#system("cd ./vendor/SMLoadr && ./SMLoadr-linux-x64 -u #{queue_item["link"]}")
				system("echo yeah")
			end
		end 
      # loop do
      #   @queue.pop
      #   say "Consumed a widget: #{@queue.size} in queue..."
      # end
     puts @queue[0]
  end

  def kill
    @threads.each &:kill
  end
end

	

# persistent_queue = []
# persistent_queue = JSON.parse(File.read('tmp_app/persistent_queue1111.json'))

# #puts persistent_queue

# pc = ProducerConsumer.new(persistent_queue)
# puts "run it"
# pc.run
# sleep 0.5
# pc.kill

