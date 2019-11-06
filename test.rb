require 'thread'

work = Queue.new



producer = Thread.new do
  count = 0
  loop do
    sleep 1 # some work done by the producer
    count += 1
    puts "queuing job #{count}"
    work << "job #{count}"
  end
end

consumer = Thread.new do
  loop do
    job = work.deq
    puts "worker: #{job}"

    # some more long running job
    sleep 2
  end
end

producer.join
consumer.join