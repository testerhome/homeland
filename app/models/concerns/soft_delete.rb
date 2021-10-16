# frozen_string_literal: true

module SoftDelete
  extend ActiveSupport::Concern

  included do
    default_scope -> { where(deleted_at: nil) }

    alias_method :destroy!, :destroy
  end

  def destroy
    run_callbacks(:destroy) do
      if persisted?
        t = Time.now.utc
        update_columns(deleted_at: t, updated_at: t)
        send_broadcast
      end

      @destroyed = true
    end
    freeze
  end

  def deleted?
    deleted_at.present?
  end

  def send_broadcast
    if self.is_a? Topic
      broadcast(:topic_deleted, self)
    end

    if self.is_a? Reply
      broadcast(:reply_deleted, self)
    end
  end
end
