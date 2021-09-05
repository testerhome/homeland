module Homeland::Activities
  module EventsHelper
    def event_error_msg(attribute_name, event)
      return "" unless event.errors.any?

      sanitize "<p class=\"inline-error-info\">#{event.errors[attribute_name].join(",").strip}</p>".html_safe
    end

    def event_date_str(time, format = "%Y-%m-%d")

      w = case time.strftime("%A")
      when "Sunday"
        "周日"
      when "Monday"
        "周一"
      when "Tuesday"
        "周二"
      when "Wednesday"
        "周三"
      when "Thursday"
        "周四"
      when "Friday"
        "周五"
      when "Saturday"
        "周六"
      end

      "#{time.strftime(format)} #{w}"
    end
  end
end
