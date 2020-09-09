# frozen_string_literal: true

class OpencoursesController < ApplicationController
  helper_method :feed_node_topics_url

  def feed_node_topics_url
    # super.feed_node_topics_url(id: 25)
  end

  def index
    @node = Node.find(Node.opencourse_id)
    @suggest_topics = Topic.where(node_id: @node.id).without_draft.suggest_all_parts.limit(4)
    suggest_topic_ids = @suggest_topics.map(&:id)
    @topics = @node.topics.last_actived
    @topics = @topics.where.not(id: suggest_topic_ids) if suggest_topic_ids.count > 0
    @topics = @topics.includes(:user).page(params[:page])
    @page_title = "#{t('menu.open_course')} - #{t('menu.topics')}"
    render "/topics/index" if stale?(etag: [@node, @suggest_topics, @topics], template: "/topics/index")
  end
end
