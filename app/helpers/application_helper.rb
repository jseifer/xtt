# Methods added to this helper will be available to all templates in the application.
require 'ostruct'
require 'md5'

module ApplicationHelper

  def sidebar_box(name, &block)
    sbox = OpenStruct.new
    sbox.name= name
    yield sbox
    render :file => '/components/sidebar_box', :locals => {:sbox => sbox}
  end
  
  # Doesn't work.  Requries a Level 6 in Rails Voodoo. 
  def main_box(name, &block)
    mbox = ContentBox.new(name)
    yield mbox
    render :file => '/components/main_box', :locals => {:mbox => mbox}
  end
  
  def fullscreen_box(name, &block)
    fbox = FullScreenBox.new(name)
    yield fbox
    render :file => '/components/fullscreen_box', :locals => {:fbox => fbox}
  end
  
  def gravatar_for(user)
    image_tag "http://www.gravatar.com/avatar.php?gravatar_id=#{MD5.hexdigest user.email}&rating=R&size=48"
  end
end
