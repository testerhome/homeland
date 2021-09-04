module Homeland
  module Activities
    module ApplicationHelper
      include ::Webpacker::Helper

      def current_webpacker_instance
        Homeland::Activities.webpacker
      end
    end
  end
end
