class NotifyAppendJob < ApplicationJob
  queue_as :notifications

  def perform(append_id)
    Append.notify_append_created(append_id)
  end
end
