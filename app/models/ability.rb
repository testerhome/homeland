# frozen_string_literal: true

class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(u)
    @user = u
    if @user.blank? || !@user.certified?
      roles_for_anonymous
    elsif @user.admin?
      can :manage, :all
      ids = User.where(state: :maintainer).pluck(:node_assignment_ids).reduce { |x, y| x | y }
      cannot [:destroy, :update], Node, id: ids
    elsif @user.member?
      roles_for_members
      role_for_invitecode
    elsif @user.hr?
      roles_for_members
    elsif @user.vip?
      roles_for_members
      role_for_invitecode
      roles_for_vip
    elsif @user.maintainer?
      roles_for_members
      role_for_invitecode
      custom_roles_for_maintainers
    else
      roles_for_anonymous
    end
  end

  protected

    # 普通会员权限
    def roles_for_members
      roles_for_topics
      roles_for_replies
      roles_for_comments
      roles_for_photos
      roles_for_teams
      roles_for_team_users
      roles_for_columns
      roles_for_articles
      basic_read_only
    end

    # 未登录用户权限
    def roles_for_anonymous
      cannot :manage, :all
      basic_read_only
    end

  def role_for_invitecode
    can :create, InviteCode
    can %i[read], InviteCode, creater_id: user.id
  end

    # Vip 用户权限
    def roles_for_vip
      can :create, Team
    end

    # 自定义版主权限
    def custom_roles_for_maintainers
      can :create, Team
      can :manage, Topic, node_id: user.node_assignment_ids
      topic_ids = Topic.where(node_id: user.node_assignment_ids).pluck(:id)
      can :manage, Reply, topic_id: topic_ids
    end

    # 版主权限
    def roles_for_maintainer
      can :create, Team
      can :manage, Node
      can :manage, Section
      can :manage, Topic
      can :lock_node, Topic
      can :manage, Reply
    end

    def roles_for_topics
      unless user.newbie?
        can :create, Topic unless Setting.is_night_curfew?
      end
      can %i[favorite unfavorite follow unfollow], Topic
      can %i[update open close], Topic, user_id: user.id
      can :change_node, Topic, user_id: user.id, lock_node: false
      can :destroy, Topic do |topic|
        topic.user_id == user.id && topic.replies_count == 0
      end
    end

    def roles_for_replies
      # 新手用户晚上禁止回帖，防 spam，可在面板设置是否打开
      can :create, Reply unless Setting.is_night_curfew?
      can %i[update destroy], Reply, user_id: user.id
      cannot %i[create update destroy], Reply, topic: { closed?: true }
      can %i[reply_suggest reply_unsuggest], Reply do |reply|
        reply.topic.user_id == user.id
      end
    end

    def current_lock_reply?
      return false unless user.newbie?
      return false unless Setting.reject_newbie_reply_in_the_evening?
      Time.zone.now.hour >= Setting.night_curfew_start.to_i || Time.zone.now.hour <= Setting.night_curfew_end.to_i
    end

    def roles_for_photos
      can :tiny_new, Photo
      can :create, Photo
      can :update, Photo, user_id: user.id
      can :destroy, Photo, user_id: user.id
    end

    def roles_for_comments
      can :create, Comment
      can :update, Comment, user_id: user.id
      can :destroy, Comment, user_id: user.id
    end

    def roles_for_teams
      if not user.newbie?
        can :create, Team
      end
      can [:update, :destroy], Team do |team|
        team.owner?(user)
      end
    end

    def roles_for_team_users
      can :read, TeamUser, user_id: user.id
      can :accept, TeamUser, user_id: user.id
      can :reject, TeamUser, user_id: user.id
      can :update_user, TeamUser, user_id: user.id
      can [:accept_join, :reject_join, :show_approve], TeamUser do |team_user|
        team_user.team.owner?(user)
      end
    end

    def roles_for_columns
      if user.column_editor? && !user.newbie?
        can :create, Column
      end
      can %i[update], Column, user_id: user.id
      can :destroy, Column do |column|
        column.user_id == user.id
      end
    end
  
    def roles_for_articles
      if user.column_editor? && !user.newbie?
        can :create, Article
      else
        cannot :create, Article
      end
      can %i[favorite unfavorite follow unfollow], Article
      can %i[update open close append], Article, user_id: user.id
      can :change_node, Article, user_id: user.id, lock_node: false
      can :destroy, Article do |article|
        article.user_id == user.id && article.replies_count == 0
      end
    end

    def basic_read_only
      can %i[read feed node], Topic
      can %i[read reply_to], Reply
      can :read, Photo
      can :read, Section
      can :read, Comment
      can :read, Team
      can :requestjoin, Team
    end
end
