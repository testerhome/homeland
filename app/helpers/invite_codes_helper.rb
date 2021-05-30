# frozen_string_literal: true

module InviteCodesHelper
  def name_tag(user_id)
    return "" if user_id.blank?
    user = User.find user_id
    login = user.login
    label = user.name.blank? ? user.login : user.name
    link_to(label, "/#{login}")
  end

  def expired_tag(expired)
    if expired
      content_tag(:span, "过期", class: "label label-default")
    else
      content_tag(:span, "正常", class: "label label-info")
    end
  end
end
