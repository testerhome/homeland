class CreditListener
  # 创建了帖子 走的model， 方便API 也进入
  # 注意， 这块是排除了 question 的 得分的
  def topic_created(topic)
    user = topic.user
    return unless topic.tech_node?

    num = Setting.tech_topic_created_credit

    user.credit_operate(
      category: "topic_created",
      reason: "创建技术节点 #{topic.title}",
      num: num,
      operator: user.id,
      model_id: topic.id,
      model_type: "Topic",
      meta: {

      }
    )
  end

  def topic_deleted(topic)

    # 找到基于帖子的所有积分操作
    CreditRecord.where(model_type: "Topic", model_id: topic.id).group(:user_id).sum(:num).each do |user_id, sum|
      user = User.find_by_id user_id
      next if user.nil?
      user.credit_operate(
        category: "topic_deleted",
        reason: "#{topic.title} 被删除， 相关得分被扣除",
        num: sum * -1,
        operator: user.id,
        model_id: topic.id,
        model_type: "Topic",
        meta: {

        }
      )
    end

  end

  def reply_deleted(reply)
    # 找到两处，一处是帖子作者， 积分要删除， 一处是发评论的人， 积分要清零

    # 先处理给发帖人的奖励
    topic = reply.topic
    user = topic.user

    author_reward_record = CreditRecord.where(user: user, model_type: "Topic", category: "topic_user_reply_record").first
    if author_reward_record
      user.credit_operate(
        category: 'cancel_topic_user_reply_reward_for_deleting_reply',
        reason: '您帖子的评论被删除， 这条评论积分被撤回',
        num: author_reward_record.num * -1,
        operator: user.id,
        model_id: topic.id,
        model_type: "Topic",
        meta: {
          reply_id: reply.id
        }
      )
    end


    # 再处理评论人的得分
    reply_user = reply.user
    reply_reward_record = CreditRecord.where(user: reply_user, model_type: "Topic", category: "topic_reply").where("meta->> 'reply_id' = '?' ", reply.id).first
    if reply_reward_record
      reply_user.credit_operate(
        category: 'cancel_reply_reward_for_deleting_reply',
        reason: '帖子的评论被删除， 回复积分被撤回',
        num: reply_reward_record.num * -1,
        operator: reply_user.id,
        model_id: topic.id,
        model_type: "Topic",
        meta: {
          reply_id: reply.id
        }
      )
    end
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
    CreditRecord.where(model_type: "Topic", model_id: topic.id).group(:user_id).sum(:num).each do |user_id, sum|
      user.credit_operate(
        category: "topic_ban",
        reason: "#{topic.title} 被禁止， 相关得分被扣除",
        num: num * -1,
        operator: user.id,
        model_id: topic.id,
        model_type: "Topic",
        meta: {

        }
      )
    end
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
        reason: "人员参与评论帖子#{topic.title}奖励 ",
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
      reply_user.credit_operate(
        category: "topic_reply",
        reason: "参与帖子#{topic.title}评论奖励",
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
        reason: "您的帖子#{topic.title}被用户赞赏",
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
        reason: "帖子#{reply.topic.title}回复被用户赞赏",
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
        reason: "帖子#{topic.title}被用户取消赞赏",
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
        reason: "帖子#{topic.title}的回复被用户取消赞赏",
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


  def user_created(user)
    # 一个是默认奖励
    user.credit_operate(
      category: "user_create",
      reason: "用户注册奖励",
      num: Setting.registered_credit,
      operator: user.id,
      model_id: user.id,
      model_type: "User",
      meta: {
      }
    )
  end

  # 用户登录
  def user_login(user)
    second_to_next_day = (Time.current.beginning_of_day + 1.day).to_i - Time.current.to_i
    num = Setting.login_credit
    Rails.cache.fetch("login_#{Date.today}-#{user.id}", expires_in: second_to_next_day) do
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