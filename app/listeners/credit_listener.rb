class CreditListener
  # 创建了帖子 走的model， 方便API 也进入
  def topic_created(topic)
    Rails.logger.info "topic #{topic} created"
  end

  # 帖子被置为普通
  def normal_topic(topic, operator:)
  end

  # 帖子被ban
  def ban_topic(topic,  operator:, reason:)
  end

  # 加精
  def excellent_topic(topic, operator:)
  end

  #评论创建, 走的model， 方便API 也进入
  def reply_created(reply)

  end

  # 赞, 走的 likeable
  def action_like(likeable)
  end

  # 取消赞，走的 likeable
  def action_unlike(likeable)
  end

  # 取消最佳答案, 走的 model
  def reply_suggested_canceled(reply)
  end

  #最佳答案, 走的 model
  def reply_suggested(reply)
  end

  # 用户登录
  def user_login(user)
    Rails.logger.info "user #{user} login"
  end
end