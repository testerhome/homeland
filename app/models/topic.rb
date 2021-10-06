# frozen_string_literal: true

require "redcarpet/render_strip"

class Topic < ApplicationRecord
  include Wisper::Publisher # 加入监听器
  include SoftDelete, MarkdownBody, Mentionable, MentionTopic, Closeable, Searchable, UserAvatarDelegate
  include Topic::Actions, Topic::AutoCorrect, Topic::Search, Topic::Notify, Topic::RateLimit

  # 临时存储检测用户是否读过的结果
  attr_accessor :read_state

  belongs_to :modified_admin, class_name: "User", optional: true
  belongs_to :real_user, class_name: "User", required: false
  belongs_to :user, inverse_of: :topics, counter_cache: true, required: false
  belongs_to :team, counter_cache: true, required: false
  belongs_to :node, counter_cache: true, required: false
  belongs_to :last_reply_user, class_name: "User", required: false
  belongs_to :last_reply, class_name: "Reply", required: false
  has_many :replies, dependent: :destroy
  has_many :appends

  validates :user_id, :title, :body, :node_id, presence: true

  validate :check_topic_ban_words

  counter :hits, default: 0

  delegate :login, to: :user, prefix: true, allow_nil: true
  delegate :body, to: :last_reply, prefix: true, allow_nil: true

  # scopes
  scope :last_actived,       -> { order(last_active_mark: :desc) }
  scope :suggest,            -> { where("suggested_at IS NOT NULL").order(suggested_at: :desc) }
  scope :no_suggest,         -> { where("suggested_at IS NULL and suggested_node is NULL") }
  scope :without_suggest,    -> { where(suggested_at: nil) }
  scope :suggest_all_parts,  -> { where("suggested_at IS NOT NULL").order(suggested_at: :desc) }
  scope :high_likes,         -> { order(likes_count: :desc).order(id: :desc) }
  scope :high_replies,       -> { order(replies_count: :desc).order(id: :desc) }
  scope :last_reply,         -> { where("last_reply_id IS NOT NULL").order(last_reply_id: :desc) }
  scope :with_replies_or_likes,       -> { where("topics.replies_count >= 1 or topics.likes_count >= 1") }
  scope :no_reply,           -> { where(replies_count: 0) }
  scope :popular,            -> { where("likes_count > 5") }
  scope :without_ban,        -> { where.not(grade: :ban) }
  scope :without_hide_nodes, -> { exclude_column_ids("node_id", Topic.topic_index_hide_node_ids) }

  scope :in_seven_days,         -> { where("topics.created_at >= ?", 1.week.ago) }
  scope :open, -> { where("closed_at IS NULL").order(created_at: :desc) }

  scope :without_node_ids,   ->(ids) { exclude_column_ids("node_id", ids) }
  scope :without_users,      ->(ids) { exclude_column_ids("user_id", ids) }
  scope :exclude_column_ids, ->(column, ids) { ids.empty? ? all : where.not(column => ids) }
  scope :without_columns, ->(ids) { where.not("column_id" => ids).or(where(column_id: nil)) }

  scope :without_nodes, lambda { |node_ids|
    ids = node_ids + Topic.topic_index_hide_node_ids
    ids.uniq!
    exclude_column_ids("node_id", ids)
  }
  scope :without_draft, -> { where(draft: false) }
  scope :with_public_articles, -> { where(article_public: true) }

  scope :public_and_enterprise_topics, -> {joins(:user).where("users.state between ? and ?", User::MIN_STATE_FOR_PUBLIC_MEMBER, User::MAX_STATE_FOR_ENTERPRISE)}
  scope :public_members_topic, -> {joins(:user).where("users.state between ? and ?", User::MIN_STATE_FOR_PUBLIC_MEMBER, User::MAX_STATE_FOR_PUBLIC_MEMBER)}
  scope :enterprise_members_topic, -> {joins(:user).where("users.state between ? and ?", User::MIN_STATE_FOR_ENTERPRISE, User::MAX_STATE_FOR_ENTERPRISE)}

  # 首页， 节点使用的正常帖子， + 公众合作号+ 企业签约号+任意角色加精
  scope :with_filter_public_end_enterprise, -> {
    joins(:user).where("users.state between ? and ?", 1, 99)
    # 其中 public_cooperation  是 工种合作账号， enterprise——subscriber 为企业签约账号， 这两个是需要显示的
    .or(where("users.state" => [User.states[:public_cooperation], User.states[:enterprise_subscriber]]))
    .or(where("topics.grade" => :excellent))
    }


  before_save { self.node_name = node.try(:name) || "" }
  before_create { self.last_active_mark = Time.now.to_i }
  after_create_commit :broadcast_topic_created

  def self.fields_for_list
    columns = %w[body who_deleted]
    select(column_names - columns.map(&:to_s))
  end

  def full_body
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
    ([markdown.render(self.body)] + self.replies.pluck(:body)).join('\n\n')
  end

  def self.topic_index_hide_node_ids
    Setting.node_ids_hide_in_topics_index.collect(&:to_i)
  end

  # 所有的回复编号
  def reply_ids
    Rails.cache.fetch([self, "reply_ids"]) do
      self.replies.order("id asc").pluck(:id)
    end
  end

  def topic_type
    (self[:type] || "Topic").underscore.to_sym
  end

  def is_article?
    topic_type == :article
  end

  def update_last_reply(reply, force: false)
    # replied_at 用于最新回复的排序，如果帖着创建时间在一个月以前，就不再往前面顶了
    return false if reply.blank? && !force

    self.last_active_mark      = Time.now.to_i if created_at > 1.month.ago
    self.replied_at            = reply.try(:created_at)
    self.replies_count         = replies.without_system.count
    self.last_reply_id         = reply.try(:id)
    self.last_reply_user_id    = reply.try(:user_id)
    self.last_reply_user_login = reply.try(:user_login)

    save
  end

  def update_when_append(append, opts = {})
    return false if append.blank? && !opts[:force]
    update!(last_active_mark: Time.now.to_i)
  end

  # 更新最后更新人，当最后个回帖删除的时候
  def update_deleted_last_reply(deleted_reply)
    return false if deleted_reply.blank?
    return false if last_reply_user_id != deleted_reply.user_id

    previous_reply = replies.without_system.where.not(id: deleted_reply.id).recent.first
    update_last_reply(previous_reply, force: true)
  end

  def floor_of_reply(reply)
    reply_index = reply_ids.index(reply.id)
    reply_index + 1
  end

  def save_with_checking_node
    save
    if previous_changes["draft"] == [true, false]
      update!(created_at: Time.now)
      update!(last_active_mark: Time.now.to_i)
    end
    update_user_if_related_to_anonymous
  end

  def belongs_to_nickname_node?
    return false if node.nil?
    node.nickname_node?
  end

  def check_topic_ban_words
    if User.redis.SISMEMBER("blocked_users", user_id) == 1
      errors.add(:base, "由于你经常发布无意义的内容或者敏感词，屏蔽一天！")
    else
      ban_words = Setting.ban_words_on_body.collect(&:strip)
      for ban_word in ban_words
        if body && body.strip.downcase.include?(ban_word.downcase) || title.strip.downcase.include?(ban_word.downcase)
          add_to_blocked_user
          errors.add(:base, "请勿发布无意义的内容或者敏感词，请勿挑战！")
        end
      end
    end
  end

  def add_to_blocked_user
    key = user_id.to_s + "-" + Time.now.strftime("%Y-%m-%d")
    hit_blacklist = User.redis.get(key)
    if not hit_blacklist
      User.redis.set(key, 1)
      User.redis.expire(key, 86400)
    else
      hit_blacklist_counter = hit_blacklist.to_i
      if hit_blacklist_counter <= 5
        User.redis.incr(key)
      else
        User.redis.sadd("blocked_users", user_id)
        User.redis.expire("blocked_users", 86400)
      end
    end
  end

  def update_user_if_related_to_anonymous
    # 如果是更新节点，那么节点话题可能已经包含有回复数据了
    return unless self.node_id_previously_changed?
    current = self.node_id_previous_change.second
    previous = self.node_id_previous_change.first

    if Node.find(current).nickname_node?
      replies = self.replies
      replies.each { |r| r.update(user_id: User.anonymous_user_id, real_user: r.user) }

      if user.id != User.anonymous_user_id
        user_id = user.id
        self.update(user_id: User.anonymous_user_id, real_user_id: user_id)
      end
    else
      if Node.find(previous).nickname_node?
        replies = self.replies
        replies.each { |r| r.update(user: r.real_user, real_user: nil) }
        real_user_id = real_user.id
        self.update(user_id: real_user_id, real_user: nil)
      end
    end
  end

  def self.total_pages
    return @total_pages if defined? @total_pages

    total_count = Rails.cache.fetch("topics/total_count", expires_in: 1.week) do
      self.unscoped.count
    end
    if total_count >= 1500
      @total_pages = 60
    end
    @total_pages.to_i
  end

  private

  def broadcast_topic_created
    if self.node.id != Node.questions_id
      broadcast(:topic_created, self)
      # 将创建的 topic 创建广播， 可以监听此广播用来处理复杂的逻辑
    else
      broadcast(:question_created, self)
    end
  end
end
