require "socket"

class Client
	def initialize(server)
		@server = server
		@request = nil
		@response = nil
		listen
		send
		@request.join
		@response.join
		@gui = Shoes.app do
  		  	stack :margin=>20, :width=>500 do
                    		@notes = edit_box :width=>500, :height=>250
                    		subtitle "Chat shit get banged"
                    		@add = edit_line :width=>500
    
                    		@butt = button "Send" 
        	  	end
	      	end
	end

	def listen
		@response = Thread.new do
			loop {
				msg = @server.gets.chomp
				puts "#{msg}"
				if msg == "This username already exists"
				  exit
				end
			}
		end
	end

	def send
		puts "Enter the username:"
		msg = $stdin.gets.chomp
		@server.puts(msg)
		puts "Enter Room name:"
		@request = Thread.new do
			loop {
				msg = $stdin.gets.chomp
				@server.puts(msg)
				if msg == ":logout"
				  exit
				end
			}
		end	
	end

	server = TCPSocket.open("localhost",3000)
	Client.new(server)
end

