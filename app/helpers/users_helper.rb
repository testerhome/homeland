# frozen_string_literal: true

require "digest/md5"

module UsersHelper
  # 生成用户 login 的链接，user 参数可接受 user 对象或者 字符串的 login
  def user_name_tag(user, options = {})
    return "匿名" if user.blank?

    user_type = :user
    login     = user
    label     = login
    name      = login

    if user.is_a? User
      user_type = user.user_type
      login     = user.login
      label     = user.name.blank? ? user.login : user.name
      name      = user.name
    end

    name ||= login
    options[:class] ||= "#{user_type}-name"
    options["data-name"] = name

    if options[:reply].present?
      reply = options.delete(:reply)

      if reply.real_user
        Faker::Config.random = random_from_two_id(reply.real_user.id, reply.topic.id)
        label = Faker::Name.name
      end
    end

    if options[:topic].present?
      topic = options.delete(:topic)

      if topic.real_user
        Faker::Config.random = random_from_two_id(topic.real_user.id, topic.id)
        label = Faker::Name.name
      end
    end
    if user.is_a? Team
      label     = user.name.blank? ? user.login : user.name
    end

    link_to(label, "/#{login}", options)
  end
  alias team_name_tag user_name_tag

  def user_name_plain_span(user, options = {})
    return "匿名" if user.blank?
    login     = user.login
    name      = user.name
    if name.blank?
      name = login
    end

    if options[:reply].present?
      reply = options.delete(:reply)

      if reply.real_user
        Faker::Config.random = random_from_two_id(reply.real_user.id, reply.topic.id)
        name = Faker::Name.name
      end
    end

    if options[:topic].present?
      topic = options.delete(:topic)

      if topic.real_user
        Faker::Config.random = random_from_two_id(topic.real_user.id, topic.id)
        name = Faker::Name.name
      end
    end

    content_tag(:span, name, class: "user-name")
  end


  def user_avatar_width_for_size(size)
    case size
    when :xs then 16
    when :sm then 32
    when :md then 48
    when :lg then 96
    else size
    end
  end

  def random_image(set)
    "https://testerhome.com/photo/anonymous_avatar/cat#{set}.png"
   end

  def user_avatar_tag(user, version = :md, link: true, timestamp: nil, reply: nil, topic: nil)
    width     = user_avatar_width_for_size(version)
    img_class = "media-object avatar-#{width}"

    return "" if user.blank?

    img =
      if user.avatar?
        image_url = user.avatar.url(version)
        image_url += "?t=#{user.updated_at.to_i}" if timestamp
        image_tag(image_url, class: img_class)
      else
        image_tag(user.letter_avatar_url(width * 2), class: img_class)
      end

    html_options = {}
    html_options[:title] = user.fullname

    if reply
      if reply.real_user
        Faker::Config.random = random_from_two_id(reply.real_user.id, reply.topic.id)
        set = ((reply.real_user.id % 2 + 1) + (reply.topic.id % 2 + 1)) % 5 + 1
        img = image_tag(random_image(set), class: img_class)
      end
    end

    if topic
      if topic.real_user
        Faker::Config.random = random_from_two_id(topic.real_user.id, topic.id)
        set = ((topic.real_user.id % 2 + 1) + (topic.id % 2 + 1)) % 5 + 1
        img = image_tag(random_image(set), class: img_class)
      end
    end

    if link
      link_to(raw(img), "/#{user.login}", html_options)
    else
      raw img
    end
  end

  alias team_avatar_tag user_avatar_tag

  def user_level_tag(user, show_whole: true)
    return "" if user.blank?
    level_name = user.level_name
    level_name = user.level_name.to_s.split('-').first unless show_whole

    content_tag(:span, level_name, class: "badge-role role-#{user.level}", style: "background: #{user.level_color};")
  end

  def block_node_tag(node)
    return "" if current_user.blank?
    return "" if node.blank?

    blocked     = current_user.block_node?(node)
    class_names = "btn btn-default button-block-node"
    icon        = '<i class="fa fa-eye-slash"></i>'

    if blocked
      link_to raw("#{icon} <span>取消屏蔽</span>"), "#", title: "忽略后，社区首页列表将不会显示这里的内容。", "data-id" => node.id, class: "#{class_names} active"
    else
      link_to raw("#{icon} <span>忽略节点</span>"), "#", title: "", "data-id" => node.id, class: class_names
    end
  end

  def block_user_tag(user)
    return "" if current_user.blank?
    return "" if user.blank?
    return "" if current_user.id == user.id

    blocked     = current_user.block_user?(user)
    class_names = "button-block-user btn btn-default btn-block"
    icon        = '<i class="fa fa-eye-slash"></i>'

    if blocked
      link_to raw("#{icon} <span>取消屏蔽</span>"), "#", title: "忽略后，社区首页列表将不会显示此用户发布的内容。", "data-id" => user.login, class: "#{class_names} active"
    else
      link_to raw("#{icon} <span>屏蔽</span>"), "#", title: "", "data-id" => user.login, class: class_names
    end
  end

  def follow_user_tag(user, opts = {})
    return "" if current_user.blank?
    return "" if user.blank?
    return "" if current_user.id == user.id
    followed = current_user.follow_user_ids.include?(user.id)
    opts[:class] ||= "btn btn-primary btn-block"

    class_names = "button-follow-user #{opts[:class]}"
    icon        = '<i class="fa fa-user"></i>'
    login       = user.login

    if followed
      link_to raw("#{icon} <span>已关注</span>"), "#", "data-id" => login, class: "#{class_names} active"
    else
      link_to raw("#{icon} <span>关注</span>"), "#", title: "", "data-id" => login, class: class_names
    end
  end

  # 根据父权限节点，获取子权限节点， 注意 master_state_category 是用 - 连接起来的权限

  def user_states_info
    User.states.map {|k, v| [k,v,I18n.t("activerecord.enums.user.state.#{k}") ]}
  end

  def audits_info
    Topic.audit_statuses.map {|k, v| [I18n.t("activerecord.enums.audit.#{k}"), v ]}
  end

  def user_sub_state_options(master_state_category)
    return User.state_options if master_state_category.blank?
    tmp = master_state_category.split("-").map(&:to_i)
    states = User.states.filter { |k, v| v >= tmp[0] && v <= tmp[1] }.keys

    User.state_options.filter { |item| states.include? item.last }
  end

  def reward_user_tag(user, opts = {})
    return "" if user.blank?
    return "" unless user.reward_enabled?
    opts[:class] ||= "btn btn-success"
    link_to icon_tag("qrcode", label: "打赏支持"), main_app.reward_user_path(user), remote: true, class: opts[:class]
  end

  def user_id_wrapper(user)
    return "" if user.blank?
    user.id
  end

  private
    def random_from_two_id(user_id, topic_id)
      Random.new(user_id + topic_id)
    end
end
