require 'pry'

class A
  def hello() puts "hello world!" end
end

a = A.new

# set x to 10
x = 10

# start a REPL session
binding.pry

puts 'hello'
