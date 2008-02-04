require 'rubygems'
require 'net/toc'

require 'status'
require 'user'

module TOCMonkeypatch
  def names
    @buddies.keys
  end
  
  def buddies
    @buddies.values
  end
end

class Net::TOC::BuddyList
  include TOCMonkeypatch
end

module Net::TOC
  Debug = true
end

class Aimbo
  
  @@credentials = {
    :username => 'xttbot',
    :password => 'caboose',
    :admin    => 'courtenay187'
  }
  
  attr_accessor :client

  def initialize
    @client = Net::TOC.new(@@credentials[:username], @@credentials[:password]) 
    setup_error_notification
    setup_im
  end
  
  def setup_error_notification
    @client.on_error do |error|
      admin = @client.buddy_list.buddy_named(@@credentials[:admin])
      admin.send_im("Error: #{error}")
    end
  end
  
  def setup_im
    @client.on_im do |message, buddy|
      IM::Response.new message, buddy
    end
  end
end


aimbo = Aimbo.new
client = aimbo.client
client.connect
puts "buddy list is #{client.buddy_list.inspect}"

@users = User.find(:all, :conditions => ['aim_login is not null'])
@users.each do |user|  
  if pal = client.buddy_list.buddy_named(user.aim_login)
    puts pal.to_s
    pal.on_status do |status|
      puts "Buddy changed status to #{status}"
      # todo: hash the screen name
      File.open("buddy.#{pal.screen_name}.status.txt", "w+") do |f|
        # todo: write xml
        f.write "{ time:#{Time.now.utc.to_f}, status: '#{status}' }"
      end
    end
  end
end

client.wait


return

########################################

loop do
  buddy_name, message = *gets.chomp.split("<<",2)
  buddy_name = last_buddy if buddy_name == ""

  unless buddy_name.nil? or message.nil?
    last_buddy = buddy_name
    client.buddy_list.buddy_named(buddy_name).send_im(message)
  end
end

return
#################

client do |msg, buddy|
  puts "Talking to #{buddy.screen_name} #{msg}"
 buddy.send_im "Hi, #{buddy.screen_name}"
end

  #@responses_line_counter[screen_name] = 0 if @responses_line_counter[screen_name].nil?

  #curr_line     = @responses_line_counter[screen_name] % @responses.size
  #next_response = @responses[curr_line]

  #@responses_line_counter[screen_name] += 1

  sleep rand(5)
  buddy.send_im(next_response)

  # Save counter after each response.
  #File.open(@filename, "w+") do |f|
  #  Marshal.dump(@responses_line_counter, f)
  #end
#end
