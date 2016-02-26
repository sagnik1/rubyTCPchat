#!/usr/bin/env ruby -w
require "socket"
class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "This username already exists"
            Thread.kill self
          end
        end
        
        room_name = client.gets.chomp.to_sym
        @connections[:rooms][nick_name] = room_name
         
        
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        client.puts "Connection established, Thank you for joining! Happy chatting"
        
      	@connections[:rooms].each do |other_client_name, curr_room_name|
          if curr_room_name == @connections[:rooms][nick_name]
            unless other_client_name == nick_name
                @connections[:clients][other_client_name].puts "#{nick_name.to_s} has joined the chat!"
            end
          end
        end
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def listen_user_messages( username, client )
    loop {
      msg = client.gets.chomp
      if msg == ":logout"
        @connections[:clients].each do |other_name, other_client|
          unless other_name == username
            other_client.puts "#{username.to_s} has logged out!"
          end
        end
        @connections[:clients].delete(username)
        @connections[:rooms].delete(username)
      	break
      end
      @connections[:rooms].each do |other_client_name, room_name|
        if room_name == @connections[:rooms][username]
          unless other_client_name == username
            @connections[:clients][other_client_name].puts "#{username.to_s}: #{msg}"
          end
        end
      end
    }
  end
end

Server.new( 3000, "localhost" )
