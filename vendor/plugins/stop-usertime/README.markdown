# Stop::UserTime

[Stop... UserTime!](http://dancejam.com/videos/1054584095-mc-hammer-cant-touch-this-asian-sty)

## Usage

There are three steps to using Stop::UserTime.

 * install the plugin
 * configure with your key
 * update layout with the usertime helper


### Install

    script/plugin install git@github.com:railsmachine/stop-usertime.git


### Configuration

Next, you need to add an initialize for your app's settings, perhaps in config/initializers/usertime_config.rb

    Stop::UserTime.configure do |config|
      config.key = "redacted"
    end

Stop::UserTime only will enable UserTime reporting for production by default. If you need others, it's easy to add:

    Stop::UserTime.configure do |config|
      config.key = "redacted"
      config.environments = %w(staging production)
    end


Stop::UserTime will send along information about the current controller and action, defaulting to ControllerClass#action_name. You can override this with a lamda:


    Stop::UserTime.configure do |config|
      config.key = "redacted"
      config.label_generator do |view|
         "Oh oh oh... oh oh... stop... #{view.controller.class}##{view.controller.action_name}"
      end
    end

If you need even finer control of this, you can just override the `usertime_label` method to pull to do whatever logic you might need to do.

   module ApplicationHelper
     def usertime_label
       # this code hidden to protect the innocent
     end
   end

### Layout

UserTime works by adding extra JavaScrip at the beginning and end of your &lt;head&gt;. The `usertime` can handle inserting this, and making sure it has the correct key and label.


    <html>
      <head>
        <%- usertime do %>
          <title>My awesome site</title>
          <%= javascript_include_tag :defaults %>
        <% end %>
      </head>
      <body>
        <%= yield
      </body>
    </html>

## Credit

Copyright (c) 2010 Josh Nichols, released under the MIT license
