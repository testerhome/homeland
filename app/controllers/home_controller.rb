# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @excellent_topics = topics_scope.no_suggest.excellent.recent.fields_for_list.limit(20).to_a
    @suggest_topics = topics_scope.suggest.fields_for_list.limit(4).to_a
    @latest_topics = topics_scope.no_suggest.recent.without_hide_nodes.with_replies_or_likes.with_filter_public_end_enterprise.fields_for_list.limit(6).to_a
    @hot_topics = topics_scope.in_seven_days.high_replies.no_suggest.with_replies_or_likes.with_filter_public_end_enterprise.fields_for_list.limit(10).to_a
    @users = User.normal.without_team.new_guy.limit(100).select { |user| !user.admin? }[0..9]

    bugs_node = Node.find_by_id Node.bugs_id
    if bugs_node
      @open_bugs = bugs_node.topics.without_draft.open.limit(5).to_a
    end
    if Setting.has_module?(:opensource_project)
      @opensource_projects = OpensourceProject.includes(:user).published.latest.limit(5).to_a
    end
  end

  def uploads
    return render_404 if Rails.env.production?

    # This is a temporary solution for help generate image thumb
    # that when you use :file upload_provider and you have no Nginx image_filter configurations.
    # DO NOT use this in production environment.
    format, version = params[:format].to_s.split("!")
    filename = [params[:path], format].join(".")
    pragma = request.headers["Pragma"] == "no-cache"
    thumb = Homeland::ImageThumb.new(filename, version, pragma: pragma)
    if thumb.exists?
      send_file thumb.outpath, type: "image/jpeg", disposition: "inline"
    else
      render plain: "File not found", status: 404
    end
  end

  def error_404
    render_404
  end

  def markdown
  end

  def status
    render plain: "OK #{Time.now.iso8601}"
  end

  private

    def topics_scope(base_scope = Topic)
      scope = base_scope.fields_for_list.without_hide_nodes.without_draft.without_ban.with_public_articles
      if current_user
        scope = scope.without_nodes(current_user.block_node_ids)
        scope = scope.without_users(current_user.block_user_ids)
        scope = scope.without_columns(current_user.block_column_ids)
      end

      # must include :user, because it's uses for _topic.html.erb fragment cache_key
      scope.includes(:user)
    end
end
