# frozen_string_literal: true

class User
  # 对话题、回帖点赞
  module Likeable
    include Wisper::Publisher # 加入监听器
    extend ActiveSupport::Concern

    included do
      # Action for Topic
      action_store :like, :topic, counter_cache: true
      # Action for Article
      action_store :like, :article, counter_cache: true
      # Action for Reply
      action_store :like, :reply, counter_cache: true
      # Action for OpensourceProject
      action_store :like, :opensource_project, counter_cache: true
    end

    # 赞
    def like(likeable)
      return false if likeable.blank?
      return false if likeable.user_id == self.id
      broadcast(:action_like, likeable)
      self.create_action(:like, target: likeable)
      Notification.notify_likeable(likeable.user_id, likeable.class.name ,likeable.id, self.id)
    end

    # 取消赞
    def unlike(likeable)
      return false if likeable.blank?
      return false if likeable.user_id == self.id
      broadcast(:action_unlike, likeable)
      self.destroy_action(:like, target: likeable)
    end

    # 是否喜欢过
    def liked?(likeable)
      self.find_action(:like, target: likeable).present?
    end

    # 基于一组 Reply 获取用户已经喜欢过的内容
    def like_reply_ids_by_replies(replies)
      return [] if replies.blank?
      return [] if self.like_reply_ids.blank?
      # Intersection between reply ids and user like_reply_ids
      self.like_reply_actions.where(target_id: replies.collect(&:id)).pluck(:target_id)
    end
  end
end
