# frozen_string_literal: true

module Mentionable
  extend ActiveSupport::Concern

  included do
    before_save :extract_mentioned_users
    after_create :send_mention_notification
    after_destroy :delete_notification_mentions
  end

  def delete_notification_mentions
    Notification.where(notify_type: "mention", target: self).delete_all
  end

  def mentioned_users
    User.without_team.where(id: mentioned_user_ids)
  end

  def mentioned_user_logins
    # 用于作为缓存 key
    ids_md5 = Digest::MD5.hexdigest(mentioned_user_ids.to_s)
    Rails.cache.fetch("#{self.class.name.downcase}:#{id}:mentioned_user_logins:#{ids_md5}") do
      self.mentioned_users.pluck(:login)
    end
  end

  def extract_mentioned_users
    logins = body.scan(/@([#{User::LOGIN_FORMAT}]{3,20})/).flatten.map(&:downcase)
    logins.delete(user.login.downcase) if user

    if logins.any?
      self.mentioned_user_ids = User.without_team.where("lower(login) IN (?)", logins).limit(5).pluck(:id)
    end


    # add Reply to user_id
    if self.respond_to?(:reply_to)
      reply_to_user_id = self.reply_to&.user_id
      if reply_to_user_id
        self.mentioned_user_ids << reply_to_user_id
      end
    end
  end

  private

    def no_mention_users
      [user]
    end

    def send_mention_notification
      # 草稿跟私有社团的情况下不发送提到通知
      if self.class.name == "Topic"
        return if self.draft
        return if self.private_org
      end

      # 私有社团以及仅作者可见的情况下不发送提到通知
      if self.class.name == "Reply"
        return if self&.topic.private_org
        return if self.exposed_to_author_only?
      end

      users = mentioned_users - no_mention_users
      Notification.bulk_insert(set_size: 100) do |worker|
        users.each do |user|
          note = {
            notify_type: "mention",
            actor_id: self.user_id,
            user_id: user.id,
            target_type: self.class.name,
            target_id: self.id
          }

          if self.class.name == "Reply"
            note[:second_target_type] = "Topic"
            note[:second_target_id] = self.send(:topic_id)
          elsif self.class.name == "Comment"
            note[:second_target_type] = self.commentable_type
            note[:second_target_id] = self.commentable_id
          end
          worker.add(note)
        end
      end

      # Touch push to client
      # TODO: 确保准确
      users.each do |u|
        n = u.notifications.last
        n.realtime_push_to_client
      end
    end
end
