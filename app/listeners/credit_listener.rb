class CreditListener
  # 创建了帖子 走的model， 方便API 也进入
  # 注意， 这块是排除了 question 的 得分的
  def topic_created(topic)
    user = topic.user
    return unless topic.tech_node?

    num = Setting.tech_topic_created_credit

    user.credit_operate(
      category: "topic_created",
      reason: "创建技术节点",
      num: num,
      operator: user.id,
      model_id: topic.id,
      model_type: "Topic",
      meta: {

      }
    )
  end

  def question_created(question)
    user = question.user
    num = Setting.question_created_credit

    user.credit_operate(
      category: "question_created",
      reason: "创建技术节点",
      num: num,
      operator: user.id,
      model_id: question.id,
      model_type: "Topic",
      meta: {

      }
    )
  end


  # 加精
  def excellent_topic(topic, operator:)
    user = topic.user
    num = Setting.excellent_topic_credit

    user.credit_operate(
      category: "excellent_topic",
      reason: "文章 #{topic.title} 加精",
      num: num,
      operator: user.id,
      model_id: topic.id,
      model_type: "Topic",
      meta: {
      }
    )
  end

  # 帖子被置为普通
  def normal_topic(topic, operator:)
    user = topic.user
    num = Setting.excellent_topic_credit

    user.credit_operate(
      category: "excellent_topic",
      reason: "文章 #{topic.title} 加精",
      num: num * -1,
      operator: user.id,
      model_id: topic.id,
      model_type: "Topic",
      meta: {
      }
    )
  end

  # 帖子被ban
  def ban_topic(topic,  operator:, reason:)
  end


  #评论创建, 走的model， 方便API 也进入
  def reply_created(reply)
    # 注意， 此处应该有两处， 一个是作者本身， 一个是参与者

    # 先处理 帖子的
    topic = reply.topic
    user = reply.topic.user
    # 当回复的人不是作者时
    if reply.user.id != user.id
      user.credit_operate(
        category: "topic_user_reply_reward",
        reason: "其他用户加入评论奖励 ",
        num: Setting.topic_user_reply_reward_credit,
        operator: user.id,
        model_id: topic.id,
        model_type: "Topic",
        meta: {
          reply_id: reply.id
        }
      )
    end

    # 再处理参与评论的评论人
    reply_user = reply.user
    # 先检测下 帖子回复行为的个数
    unless topic.reach_reply_limit?(reply_user)
      num = Setting.topic_reply_credit
      user.credit_operate(
        category: "topic_reply",
        reason: "参与帖子评论奖励",
        num: num,
        operator: reply_user.id,
        model_id: topic.id,
        model_type: "Topic",
        meta: {
          reply_id: reply.id
        }
      )
    end


  end

  # 赞, 走的 likeable
  def action_like(likeable)
    case likeable.class.to_s
    when "Topic"
      topic = likeable
      user = topic.user
      user.credit_operate(
        category: "topic_like_reward",
        reason: "帖子被用户赞赏",
        num: Setting.topic_like_credit,
        operator: user.id,
        model_id: topic.id,
        model_type: "Topic",
        meta: {
          like_user_id: likeable.user_id
        }
      )
    when "Reply"
      reply = likeable
      user = reply.user
      user.credit_operate(
        category: "reply_like_reward",
        reason: "回复被用户赞赏",
        num: Setting.reply_like_credit,
        operator: user.id,
        model_id: reply.id,
        model_type: "Reply",
        meta: {
          like_user_id: likeable.user_id,
          topic_id: reply.topic.id
        }
      )
    else
      # DO NOTHING
    end
  end

  # 取消赞，走的 likeable
  def action_unlike(likeable)
    case likeable.class.to_s
    when "Topic"
      topic = likeable
      user = topic.user
      user.credit_operate(
        category: "topic_unlike_reward",
        reason: "帖子被用户取消赞赏",
        num: Setting.topic_like_credit * -1,
        operator: user.id,
        model_id: topic.id,
        model_type: "Topic",
        meta: {
          like_user_id: likeable.user_id
        }
      )
    when "Reply"
      reply = likeable
      user = reply.user
      user.credit_operate(
        category: "reply_unlike_reward",
        reason: "回复被用户取消赞赏",
        num: Setting.reply_like_credit * -1,
        operator: user.id,
        model_id: reply.id,
        model_type: "Reply",
        meta: {
          like_user_id: likeable.user_id,
          topic_id: reply.topic.id
        }
      )
    else
      # DO NOTHING
    end
  end

  #最佳答案, 走的 model
  def reply_suggested(reply)
    user = reply.user
    num = Setting.question_best_answer_credit

    user.credit_operate(
      category: "question_best_answer_reward",
      reason: "回复被选为最佳答案",
      num: num,
      operator: user.id,
      model_id: reply.id,
      model_type: "Reply",
      meta: {
        topic_id: reply.topic.id
      }
    )
  end

  # 取消最佳答案, 走的 model
  def reply_suggested_canceled(reply)

    user = reply.user
    num = Setting.question_best_answer_credit

    user.credit_operate(
      category: "question_best_answer_reward_cancel",
      reason: "您的最佳答案被取消",
      num: num * -1,
      operator: user.id,
      model_id: reply.id,
      model_type: "Reply",
      meta: {
        topic_id: reply.topic.id
      }
    )
  end



  # 用户登录
  def user_login(user)
    second_to_next_day = (Time.current.beginning_of_day + 1.day).to_i - Time.current.to_i
    num = Setting.login_credit
    Rails.cache.fetch("login_#{Date.today}-#{user.id}", expires_in: second_to_next_day) do
      user = reply.user
      user.credit_operate(
        category: "login_reward",
        reason: "登录奖励#{Date.today}",
        num: num,
        operator: user.id,
        model_id: user.id,
        model_type: "User",
        meta: {
        }
      )
      true
    end
    Rails.logger.info "user #{user} login"
  end
end