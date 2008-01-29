# Methods added to this helper will be available to all templates in the application.
require 'ostruct'
require 'md5'

module ApplicationHelper
  include LiveTimer
  
  def box(type, name, &block)
    type = type.to_s
    box = OpenStruct.new
    box.name= name
    yield box
    render :file => "/components/#{type}_box", :locals => {:box => box}
  end
  
  def gravatar_for(user)
    image_tag "http://www.gravatar.com/avatar.php?gravatar_id=#{MD5.hexdigest user.email}&rating=R&size=48", :class => 'thumbnail'
  end
  
  def first_in_collection?(collection, index)
    collection.size == (index  + 1)
  end
  
  def update_button
    tag(:input, {:type => 'image', :src => '/images/btns/ghost.png', :class => 'btn'})
  end
  
  def save_button
    tag(:input, {:type => 'image', :src => '/images/btns/ghost.png', :class => 'btn save'})
  end
  
  def link_to_status(status)
    ret = ""
    ret << link_to(h(status.project.name), status.project) + ": " if status.project
    ret << link_to(h(status.message), status)
    ret
  end
  
  def start_time_for(status)
    status.created_at.strftime("%I:%m %p").downcase
  end
  
  def finish_time_for(status)
    status.followup.created_at.strftime("%I:%m %p").downcase
  end

end
