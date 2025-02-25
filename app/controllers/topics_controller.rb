# frozen_string_literal: true

class TopicsController < ApplicationController
  include Wisper::Publisher # 加入监听器
  include Topics::ListActions

  before_action :authenticate_user!, only: %i[new edit create update destroy waiting_audit_topics
                                              favorite unfavorite follow unfollow
                                              action favorites raw_markdown]
  load_and_authorize_resource only: %i[new edit create update destroy favorite unfavorite follow unfollow raw_markdown]
  before_action :set_topic, only: %i[edit update read destroy follow unfollow action ban append]

  def waiting_audit_topics
    @topics = Topic.where(user_id: current_user.id, deleted_at: nil).where.not(audit_status: "approved").order("created_at desc")
    if current_user.roles? :maintainer
      node_ids = current_user.node_assignment_ids
      @topics_to_be_approved_by_u = Topic.where(node: node_ids, deleted_at: nil).where.not(audit_status: "approved").order("created_at desc").page(params[:page])
      topics_can_be_managed_by_u = Topic.where(node: node_ids, deleted_at: nil).order("created_at desc")
      @replies_to_be_approved_by_u = Reply.where(topic_id: topics_can_be_managed_by_u.ids).where.not(audit_status: "approved").order("created_at desc").page(params[:page])
    end
  end

  def index
    @suggest_topics = []
    if params[:page].to_i > Topic.total_pages
      params[:page] = Topic.total_pages
    end
    if params[:page].to_i <= 1
      @suggest_topics = topics_scope.suggest.limit(3)
    end
    @topics = topics_scope.without_suggest.with_filter_public_end_enterprise.last_actived.page(params[:page])
    @page_title = t("menu.topics")
    @read_topic_ids = []
    if current_user
      @read_topic_ids = current_user.filter_readed_topics(@topics + @suggest_topics)
    end
  end

  def feed
    @topics = Topic.recent.without_draft.without_ban.without_hide_nodes.includes(:node, :user, :last_reply_user).limit(20)
    render layout: false if stale?(@topics)
  end

  def node
    @node = Node.find(params[:id])
    if params[:page].to_i > Topic.total_pages
      params[:page] = Topic.total_pages
    end
    @topics = topics_scope(@node.topics, without_nodes: false).with_filter_public_end_enterprise.last_actived.page(params[:page])
    @page_title = "#{@node.name} &raquo; #{t("menu.topics")}"
    @page_title = [@node.name, t("menu.topics")].join(" · ")
    render action: "index"
  end

  def node_feed
    @node = Node.find(params[:id])
    @topics = @node.topics.recent.limit(20)
    render layout: false if stale?([@node, @topics])
  end

  def show
    common_logic_for_show(Topic)
  end

  def show_wechat
    @topic = Topic.unscoped.includes(:user).find(params[:id])
    if @topic.deleted?
      render_404
      return
    end

    @node = @topic.node
    render template: "topics/show_wechat", handler: [:erb], layout: "wechat"
  end

  def raw_markdown
    @topic = Topic.unscoped.includes(:user).find(params[:id])
    if @topic.deleted?
      render_404
      return
    end

    @node = @topic.node
    render template: "topics/raw_markdown"
  end

  def read
    # 通知处理
    current_user&.read_topic(@topic)
    render plain: "1"
  end

  def new
    if current_user.phone_number.blank?
      return redirect_to edit_phone_setting_path, notice: "请先绑定手机号"
    end

    @topic = Topic.new(user_id: current_user.id)
    unless params[:node].blank?
      @topic.node_id = params[:node]
      @node = Node.find_by_id(params[:node])
      render_404 if @node.blank?
    end
  end

  def edit
    @node = @topic.node
  end

  def create
    @topic = Topic.new(topic_params)
    @topic.user_id = current_user.id
    @topic.node_id = params[:node] || topic_params[:node_id]
    @topic.team_id = ability_team_id
    draft_and_anonymous_save
  end

  def preview
    @body = params[:body]

    respond_to do |format|
      format.json
    end
  end

  def update
    if current_user.admin? && current_user.id != @topic.user_id
      # 管理员且非本帖作者
      @topic.modified_admin = current_user
    end

    if can?(:change_node, @topic)
      # 锁定接点的时候，只有管理员可以修改节点
      @topic.node_id = topic_params[:node_id]

      if @topic.node_id_changed? && can?(:lock_node, @topic)
        # 当管理员修改节点的时候，锁定节点
        @topic.lock_node = true
      end
    end
    @topic.team_id = ability_team_id
    @topic.title = topic_params[:title]
    @topic.body = topic_params[:body]
    @topic.cannot_be_shared = topic_params[:cannot_be_shared]
    draft_and_anonymous_save
  end

  def destroy
    @topic.destroy_by(current_user)
    redirect_to(topics_path, notice: t("topics.delete_topic_success"))
  end

  def favorite
    current_user.favorite_topic(params[:id])
    render plain: "1"
  end

  def unfavorite
    current_user.unfavorite_topic(params[:id])
    render plain: "1"
  end

  def follow
    current_user.follow_topic(@topic)
    render plain: "1"
  end

  def unfollow
    current_user.unfollow_topic(@topic)
    render plain: "1"
  end

  def ban
    authorize! :ban, @topic
  end

  def action
    authorize! params[:type].to_sym, @topic

    case params[:type]
    when "excellent"
      @topic.excellent!
      broadcast(:excellent_topic, @topic, operator: current_user)
      redirect_to @topic, notice: "加精成功。"
    when "normal"
      @topic.normal!
      broadcast(:normal_topic, @topic, operator: current_user)
      redirect_to @topic, notice: "话题已恢复到普通评级。"
    when "ban"
      params[:reason_text] ||= params[:reason] || ""
      @topic.ban!(reason: params[:reason_text].strip)
      broadcast(:ban_topic, @topic, operator: current_user, reason: params[:reason_text].strip)
      redirect_to @topic, notice: "话题已放进屏蔽栏目。"
    when "append"
      content = params[:append_body]
      if content.blank?
        redirect_to @topic, notice: "不能添加空附言。"
      else
        append = Append.new
        append.content = content
        append.topic_id = @topic.id
        append.save
        redirect_to @topic, notice: "成功添加附言。"
      end
    when "close"
      @topic.close!
      redirect_to @topic, notice: "话题已关闭，将不再接受任何新的回复。"
    when "open"
      @topic.open!
      redirect_to @topic, notice: "话题已重启开启。"
    when "audit_pass"
      @topic.audit(current_user.id, "approved", "审核通过")
      redirect_to @topic, notice: "审核通过。"
    when "audit_reject"
      @topic.audit(current_user.id, "rejected", "审核拒绝")
      redirect_to @topic, notice: "审核拒绝。"
    end
  end

  private

  def set_topic
    @topic ||= Topic.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:title, :body, :node_id, :team_id, :cannot_be_shared)
  end

  def ability_team_id
    team = Team.find_by_id(topic_params[:team_id])
    return nil if team.blank?
    return nil if cannot?(:show, team)
    team.id
  end

  def check_current_user_status_for_topic(resource)
    return false unless current_user
    # 通知处理
    current_user.read_topic(resource)
    # 是否关注过
    @has_followed = current_user.follow_topic?(resource)
    # 是否收藏
    @has_favorited = current_user.favorite_topic?(resource)
  end

  def append
  end

  def draft_and_anonymous_save
    if params[:commit] && params[:commit] == "draft"
      @topic.draft = true
    else
      @topic.draft = false
    end

    if @topic.belongs_to_nickname_node? && @topic.draft == false
      @topic.user_id = User.anonymous_user_id
      @topic.real_user_id = current_user.id
    end

    @topic.log_ip(request.remote_ip, request.headers["X-Client-Request-Port"])

    @topic.save_with_checking_node
  end

  protected

  def common_logic_for_show(class_scope)
    topic = class_scope.unscoped.includes(:user).find(params[:id])
    if topic.deleted?
      render_404
      # 如果找不到topic，就404了，代码不要继续，用return
      return
    end
    # topic 都会展示就算用户被删除
    # return redirect_to(topics_path, notice: t("topics.cannot_read_ban_topics")) if topic.user.state == 'deleted'

    # Logic just for topic
    if class_scope == Topic
      if !topic.team.blank?
        if topic.team.private?
          if !current_user
            redirect_to(new_user_session_url, alert: t("common.access_denied"))
          elsif !topic.team.has_member?(current_user) && !current_user.admin?
            redirect_to(team_path(topic.team), alert: t("teams.access_denied"))
          end
        end
      end

      if topic.user_id != current_user&.id && topic.node_id == Node.ban_id && !current_user&.admin?
        redirect_to(topics_path, notice: t("topics.cannot_read_ban_topics"))
      end
    end

    if topic.draft && topic.user_id != current_user&.id
      return redirect_to(topics_path, notice: t("topics.cannot_read_others_drafts"))
    end

    if topic.user_id != current_user&.id && topic.audit_status != "approved"
      return redirect_to(topics_path, notice: t("topics.cannot_read_not_approved_topics")) unless can?(:manage, topic)
    end

    # 展示一次，就算作阅读一次
    topic.hits.incr(1)

    @node = topic.node
    @show_raw = params[:raw] == "1"
    @can_reply = can?(:create, Reply)

    if params[:order_by] == "like"
      @replies = Reply.unscoped.where(topic_id: topic.id).order(likes_count: :desc).all
    elsif params[:order_by] == "created_at"
      @replies = Reply.unscoped.where(topic_id: topic.id).order(created_at: :desc).all
    else
      @replies = Reply.unscoped.where(topic_id: topic.id).order(:id).all
    end

    @suggest_replies = Reply.unscoped.where(topic_id: topic.id).order(:suggested_at).suggest
    @without_suggest_replies = Reply.unscoped.where(topic_id: topic.id).order(:id).without_suggest

    @user_like_reply_ids = current_user&.like_reply_ids_by_replies(@replies) || []

    check_current_user_status_for_topic(topic)
    instance_variable_set("@#{class_scope.name.downcase}", topic)
  end
end
