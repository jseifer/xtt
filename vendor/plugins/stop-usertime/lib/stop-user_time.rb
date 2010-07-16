module Stop
  module UserTime
    module ViewHelpers
      # To properly work, UserTime requires you to have some extra JavaScript bits in your <head>.
      #
      # +usertime+ is a helper to help make sure everything is in place. Call it in your view, and pass it everything that'd normally have in your head. It will handle putting the start and end javascript pieces in place.
      #
      # Here's an example:
      #
      #   <html>
      #     <head>
      #       <%- usertime do %>
      #         <title>My awesome site</title>
      #         <%= javascript_include_tag :defaults %>
      #       <% end %>
      #     </head>
      #     <body>
      #       <%= yield
      #     </body>
      #   </html>
      #
      # To properly work, you'll also need to properly +configure+ Stop::UserTime with your API +key+.
      def usertime(&block)
        key = Configuration.instance.key # TODO raise or something
        if Configuration.instance.enabled?
          concat %Q{
            <script type="text/javascript">UT={"firstbyte":Number(new Date()), "key":"#{key}", "label":"#{usertime_label}"}</script>
            <script type="text/javascript" src="http://cdn.usertimeapp.com/ut.js"></script>
          }
        end

        concat capture(&block)

        if Configuration.instance.enabled?
          concat %Q{
            <script type="text/javascript">UT.headDone()</script>
          }
        end
      end

      # Helper for calculate the label of this page reported to UserTime. This defaults to ControllerClass#action_name. You can +configure+ +label_generator+ with a lambda that takes an ActionView::Base, or just override this outright.
      def usertime_label
        Configuration.instance.label_generator.call(self)
      end
    end

    # Configure Stop::UserTime as is your want.
    def self.configure
      yield Configuration.instance if block_given?
      Configuration.instance
    end

    class Configuration
      include Singleton

      # UserTime access key. See login to http://usertimeapp.com/home then click 'setup' for your application to find the value to enter here.
      attr_accessor :key

      # Environments which UserTime will be tracking. Defaults to just production.
      attr_accessor :environments

      # A lambda used to generate the 'label' UserTime will report for each page. This will be passed the ActionView::Base instance currently being rendered
      attr_accessor :label_generator

      def environments
        @environments ||= ['production']
      end

      def label_generator
        @label_generator ||= lambda {|view| "#{view.controller.class}##{view.controller.action_name}"}
      end

      def enabled?
        environments.include?(Rails.env)
      end
    end
  end
end
