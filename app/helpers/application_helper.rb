# Methods added to this helper will be available to all templates in the application.
require 'ostruct'
require 'md5'

module ApplicationHelper

  def box(type, name, &block)
    type = type.to_s
    box = OpenStruct.new
    box.name= name
    yield box
    render :file => "/components/#{type}_box", :locals => {:box => box}
  end
  
  def gravatar_for(user)
    image_tag "http://www.gravatar.com/avatar.php?gravatar_id=#{MD5.hexdigest user.email}&rating=R&size=48"
  end
  
  def first_in_collection?(collection, index)
    collection.size == (index  + 1)
  end
end
