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

class Net::TOC::Buddy
  include TOCBuddyMonkeypatch
end

module Net::TOC
  Debug = true
end

class XttBot 
  include Net::TOC

  def initialize(*args)
    @client = Net::TOC.new *args
  end

  attr_accessor :client

  def xtt_loop
    while(true) do
      begin
        @client.connect
        puts "buddy list is #{@client.buddy_list.inspect}"
        @client.wait

      rescue Net::TOC::CommunicationError
        sleep 10 # wait, bitches
        $stderr.puts "Communication Error?"
        @client.disconnect
        @client.connect # reconnect
        
      rescue Errno::EPIPE, Errno::ECONNRESET
        sleep 10
        $stderr.puts "DISCONNECT"
        @client.disconnect
        @client.connect # reconnect
      end
    end
  end
end

class Aimbo
  
  @@credentials = {
    :username => 'xttbot',
    :password => 'caboose',
    :admin    => 'courtenay187'
  }
  
  attr_accessor :client, :xtt
  include IM
  
  def initialize
    @xtt ||= XttBot.new(@@credentials[:username], @@credentials[:password])
    @client = @xtt.client
    @error_notifier ||= setup_error_notification
    @im_notifier ||= setup_im
    @setup_away ||= setup_away
  end
  
  def setup_error_notification
    #@client.on_error do |error|
    #  admin = @client.buddy_list.buddy_named(@@credentials[:admin])
    #  admin.send_im("Error: #{error}")
    #end
  end
  
  def setup_im
    @client.on_im do |message, buddy|
      if message =~ /reload/ and buddy.screen_name == @@credentials[:admin]
        puts "Reloading IM::Response"
        #if defined?(IM)
        #  self.class.send :remove_const, :IM
        #end
        load File.dirname(__FILE__) + "/im/response.rb"
        self.class.send :include, IM
      elsif buddy.screen_name == "aolsystemmsg"
        # do nothing
      else
        IM::Response.new message, buddy
      end
    end
  end
  
  def setup_away
    @users = User.find(:all, :conditions => ['aim_login is not null'])
    @users.each do |user|  
      if pal = client.buddy_list.buddy_named(user.aim_login)
        puts pal.to_s
        pal.on_status([:available, :away, :offline]) do |status|
          if user.aim_status != status
            user.update_attribute :aim_status, status
            puts "Buddy changed status to #{status}"
            # todo: hash the screen name
            File.open(File.dirname(__FILE__) + "/tmp/buddy.#{pal.screen_name}.status.txt", "w+") do |f|
              # todo: write xml
              f.write "{ time:#{Time.now.utc.to_f}, status: '#{status}' }"
            end
          end
        end
      end
    end
  end

end

aimbo = Aimbo.new
aimbo.xtt.xtt_loop
return

#/var/www/xtt/releases/20080208021931/vendor/rails/railties/lib/commands/runner.rb:47: 
#/usr/lib64/ruby/gems/1.8/gems/net-toc-0.2/./net/toc.rb:218:in `recv': Connection reset by peer - recvfrom(2) (Errno::ECONNRESET)
#from /usr/lib64/ruby/gems/1.8/gems/net-toc-0.2/./net/toc.rb:529:in `join'
#     from /usr/lib64/ruby/gems/1.8/gems/net-toc-0.2/./net/toc.rb:529:in `wait'
#     from /var/www/xtt/releases/20080208021931/lib/aimbo.rb:91
