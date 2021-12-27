# frozen_string_literal: true

class BugsController < ApplicationController
  helper_method :feed_node_topics_url

  def feed_node_topics_url
    # super.feed_node_topics_url(id: 25)
  end


  def index
    @node = Node.find(Node.bugs_id)
    @suggest_topics = Topic.where(node_id: @node.id).without_draft.suggest_all_parts.audit_approved.limit(4)
    suggest_topic_ids = @suggest_topics.map(&:id)
    @topics = @node.topics.last_actived.without_draft.audit_approved
    @topics = @topics.where.not(id: suggest_topic_ids) if suggest_topic_ids.count > 0
    @topics = @topics.includes(:user).page(params[:page])
    @page_title = "#{t('menu.bugs')} - #{t('menu.topics')}"
    render "/topics/index"
  end
end
