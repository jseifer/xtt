# Methods added to this helper will be available to all templates in the application.
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
    image_tag "http://www.gravatar.com/avatar.php?gravatar_id=#{MD5.hexdigest user.email}&rating=R&size=48", :alt => h(user.login), :class => 'thumbnail fn'
  end
  
  def first_in_collection?(collection, index)
    collection.size == (index  + 1)
  end
  
  def update_button
    tag(:input, {:type => 'image', :src => '/images/btns/ghost.gif', :class => 'btn'})
  end
  
  def save_button
    tag(:input, {:type => 'image', :src => '/images/btns/ghost.gif', :class => 'btn save'})
  end
  
  def link_to_status(status)
    ret = ""
    ret << link_to(h(status.project.name), status.project) + ": " if status.project
    ret << link_to(h(status.message), status)
    ret
  end
  
  def start_time_for(status)
    js_formatted_time status.created_at
  end
  
  def finish_time_for(status)
    js_formatted_time status.followup.created_at
  end

  @@default_jstime_format = "%d %b, %Y %I:%M %p"
  def jstime(time, custom = nil)
    content_tag('abbr', content_tag('span', time.strftime(@@default_jstime_format), :class => "timestamp #{custom}".strip), :title => time.xmlschema, :class => 'published')
  end
  
  def js_time_ago_in_words(time)
    jstime time
  end
  
  def js_formatted_time(time)
    jstime time, :formatted
  end
  
  def display_flash(key)
    return nil if flash[key].blank?
    content_tag(:div, content_tag(:div, h(flash[key]), :class => 'mblock-cnt'), :class => 'mblock', :id => key.to_s.downcase)
  end
end
