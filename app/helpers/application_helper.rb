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
    ret << (status.project ? link_to(h(status.project.name), status.project) + ": " : "Out: ")
    ret << link_to(h(status.message), status)
    ret
  end
  
  def start_time_for(status)
    js_time status.created_at
  end
  
  def finish_time_for(status)
    js_time status.finished_at
  end

  @@default_jstime_format = "%d %b, %Y %I:%M %p"
  def js_datetime(time, rel = :datetime)
    content_tag('abbr', content_tag('span', time.utc.strftime(@@default_jstime_format), :class => :timestamp, :rel => rel), :title => time.xmlschema, :class => 'published')
  end
  
  def js_time_ago_in_words(time)
    js_datetime time, :words
  end
  
  def js_time(time)
    js_datetime time, :time
  end
  
  def js_day(time)
    js_datetime time, :day
  end
  
  def js_day_name(time)
    js_datetime time, :dayName
  end
  
  def display_flash(key)
    return nil if flash[key].blank?
    content_tag(:div, content_tag(:div, h(flash[key]), :class => 'mblock-cnt'), :class => 'mblock', :id => key.to_s.downcase)
  end

  def link_to_filtered_statuses(text, options = {})
    user_id = options.key?(:user_id) ? options[:user_id] : params[:user_id]
    filter  = options.key?(:filter)  ? options[:filter]  : params[:filter]
    args    = {:id => params[:id]}
    prefix, args  = filter.blank? ? [nil, args] : ["filtered_", args.update(:filter => filter)]
    url = 
      if controller.controller_name == 'projects'
        case user_id
          when nil, :all then send("#{prefix}project_for_all_path",  args)
          when :me       then send("#{prefix}project_for_me_path",   args.update(:user_id => :me))
          else                send("#{prefix}project_for_user_path", args.update(:user_id => user_id))
        end
      else
        send("#{prefix}user_path", args)
      end
    link_to text, url
  end
end
