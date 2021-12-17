class Admin::AuditsController < Admin::ApplicationController
  def index
    @audit_pending_topics_count = Topic.audit_pending.count
    @audit_pending_replies_count = Reply.audit_pending.count
    @audit_pending_users_count = User.audit_pending.count
  end

  def users
    @users = User.ransack(
      id_eq: params[:id_eq],
      audit_status_eq: params[:audit_status_eq],
      created_at_gteq: params[:created_at_gteq],
      created_at_lteq: params[:created_at_lteq] ? (params[:created_at_lteq] + " 23:59:59") : nil,
    ).result

    @users = @users.page(params[:page]) 
  end

  def replies
    @replies = Reply.ransack(
      topic_section_id_eq: params[:section_id_eq],
      topic_id_eq: params[:id_eq],
      topic_node_id_eq: params[:node_id_eq],
      user_name_eq: params[:user_name_eq],
      audit_status_eq: params[:audit_status_eq],
      created_at_gteq: params[:created_at_gteq],
      created_at_lteq: params[:created_at_lteq] ? (params[:created_at_lteq] + " 23:59:59") : nil,
    ).result
    @replies = @replies.includes(:user, :topic).order(created_at: :desc).page(params[:page]) 
  end

  def forbid_user
    user = User.find params[:user_id]
    user.audit_status = 'punished'
    user.state = 'deleted'
    user.save

    Reply.where(user: user).update_all(audit_status: 'punished')
    Topic.where(user: user).update_all(audit_status: 'punished')

    respond_to do |format|
      format.js
    end
  end

  def topics
    @topics = Topic.ransack(
      section_id_eq: params[:section_id_eq],
      id_eq: params[:id_eq],
      node_id_eq: params[:node_id_eq],
      user_name_eq: params[:user_name_eq],
      audit_status_eq: params[:audit_status_eq],
      created_at_gteq: params[:created_at_gteq],
      created_at_lteq: params[:created_at_lteq] ? (params[:created_at_lteq] + " 23:59:59") : nil,
    ).result
    @topics = @topics.includes(:user).order(created_at: :desc).page(params[:page])
  end

  def audit_topics
    @topic = Topic.find params[:topic_id]
    @topic.update(audit_status: params[:audit_status])

    respond_to do |format|
      format.html { 
        redirect_to [:topics, :admin, :audits, request.query_parameters], notice: "审核成功"
      }
      format.js
    end
  end

  def audit_users
    @user = User.find params[:user_id]
    @user.update(audit_status: params[:audit_status])

    respond_to do |format|
      format.html { 
        redirect_to [:users, :admin, :audits, request.query_parameters], notice: "审核成功"
      }
      format.js
    end
  end

  def audit_replies
    @reply = Reply.find params[:reply_id]
    @reply.update(audit_status: params[:audit_status])
    respond_to do |format|
      format.html {
        redirect_to [:replies, :admin, :audits, request.query_parameters], notice: "审核成功"
      }
      format.js
    end
  end

end
