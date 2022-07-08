# frozen_string_literal: true

require "digest/md5"

class User < ApplicationRecord
  attr_accessor :phone_code, :phone_captcha
  include Wisper::Publisher # 加入监听器
  include Searchable
  include UserPhoneModule, SimpleThirdLogin
  include User::Roles, User::Blockable, User::Likeable, User::Followable, User::TopicActions,
          User::GitHubRepository, User::ProfileFields, User::RewardFields, User::Deviseable,
          User::Avatar, Auditable, User::CreditOperations

  second_level_cache version: 5, expires_in: 2.weeks

  LOGIN_FORMAT = 'A-Za-z0-9\-\_\.'
  ALLOW_LOGIN_FORMAT_REGEXP = /\A[#{LOGIN_FORMAT}]+\z/
  NEW_ALLOW_LOGIN_FORMAT = "A-Za-z0-9"
  NEW_ALLOW_LOGIN_FORMAT_REGEXP = /\A[#{NEW_ALLOW_LOGIN_FORMAT}]+\z/

  ACCESSABLE_ATTRS = %i[name email_public location company bio website github twitter tagline avatar by
                        current_password password password_confirmation _rucaptcha]

  has_one :profile, dependent: :destroy

  has_many :topics, dependent: :destroy
  has_many :columns, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :photos
  has_many :oauth_applications, class_name: "Doorkeeper::Application", as: :owner
  has_many :devices
  has_many :team_users
  has_many :teams, through: :team_users
  has_many :credit_records
  has_many :credit_variant_orders

  has_one :sso, class_name: "UserSSO", dependent: :destroy

  has_many :invite_codes, dependent: :destroy, foreign_key: "creater_id"
  attr_accessor :password_confirmation, :invite_code

  validates :login, format: { with: ALLOW_LOGIN_FORMAT_REGEXP, message: "只允许数字、大小写字母" },
                    length: { in: 2..200 },
                    presence: true,
                    uniqueness: { case_sensitive: true }
  validates :name, length: { maximum: 200 }
  validates :third_unique_id, uniqueness: true, allow_nil: true

  validate :phone_check, on: :create

  validates_numericality_of :credit_sum, greater_than_or_equal_to: 0, message: "不能小于0"

  after_commit :send_welcome_mail, on: :create

  after_save :calc_credits_reward

  # after_commit :send_new_password_mail,
  #              if: proc { |record|
  #                Rails.logger.error "record.previous_changes[:email]-------------- #{record.previous_changes[:email]}"
  #                Rails.logger.error " record.previous_changes[:email].last-------------- #{ record.previous_changes[:email].last}"
  #                Rails.logger.error "record.previous_changes.key?(:email)-------------- #{record.previous_changes.key?(:email)}"
  #                record.previous_changes.key?(:email) &&
  #                  record.previous_changes[:email].first != record.previous_changes[:email].last
  #              }

  scope :hot, -> { order(replies_count: :desc).order(topics_count: :desc) }
  scope :without_team, -> { where(type: nil) }
  scope :fields_for_list, lambda {
    select(:type, :id, :name, :login, :email, :email_md5, :email_public,
           :avatar, :state, :tagline, :github, :website, :location,
           :location_id, :twitter, :team_users_count, :created_at, :updated_at)
  }
  scope :new_guy, -> { where(created_at: Time.current.all_week).where("avatar IS NOT NULL").order(created_at: :desc) }
  scope :normal, -> { where(state: 1) }
  scope :with_github, -> { where("github IS NOT NULL and github != ''") }
  scope :banzhu, -> { where(state: 90) }

  # 包含了所有公众号和企业号信息
  scope :public_and_enterprise_members, -> { where("state >=  ? and state <= ?", User::Roles::MIN_STATE_FOR_PUBLIC_MEMBER, User::Roles::MAX_STATE_FOR_ENTERPRISE) }

  # Override Devise database authentication
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login).downcase
    where(conditions.to_h).where(["(lower(login) = :value OR lower(email) = :value) and state != -1", { value: login }]).first
  end

  def self.find_by_email(email)
    fetch_by_uniq_keys(email: email)
  end

  def self.find_by_login!(slug)
    find_by_login(slug) || raise(ActiveRecord::RecordNotFound.new(slug: slug))
  end

  def self.find_by_login(slug)
    return nil unless slug.match? ALLOW_LOGIN_FORMAT_REGEXP
    fetch_by_uniq_keys(login: slug) || where("lower(login) = ?", slug.downcase).take
  end

  def self.find_by_login_or_email(login_or_email)
    login_or_email = login_or_email.downcase
    find_by_login(login_or_email) || find_by_email(login_or_email)
  end

  def valid_teams
    self.teams.reject { |t| !t.has_member?(self) }
  end

  def self.anonymous_user_id
    12
  end

  def certified?
    self.certified_at.present?
  end

  def phone_check
    # 超级密码
    if Setting.phone_verify_code_to_all.present? && Setting.phone_verify_code_to_all == self.phone_code.to_s
      return
    end

    code = Rails.cache.read("phone_code_#{self.phone_number}")

    if code.blank? || phone_code.to_s != code.to_s # 检查手机短信是否匹配正确
      errors.add(:phone_code, "不匹配")
    end
  end

  def certified
    self.certified_at = Time.now
    save(validate: false)
  end

  def calc_credits_reward
    return unless saved_change_to_attribute(:audit_status) && self.audit_status == "approved"
    broadcast(:user_created_and_audited, self)
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login).downcase
    where(conditions.to_h).where(["(lower(login) = :value OR lower(email) = :value) and state != -1", { value: login }]).first
  end

  def self.admin_users
    User.where(email: Setting.admin_email_list).to_a
  end

  def self.search(term, user: nil, limit: 30)
    following = []
    term = term.to_s + "%"
    users = User.where("login ilike ? or name ilike ?", term, term).order("replies_count desc").limit(limit).to_a
    if user
      following = user.follow_users.where("login ilike ? or name ilike ?", term, term).to_a
    end
    users.unshift(*Array(following))
    users.uniq!
    users.compact!

    users.first(limit)
  end

  def to_param
    login
  end

  def user_type
    (self[:type] || "User").underscore.to_sym
  end

  def organization?
    self.user_type == :team
  end

  def email=(val)
    self.email_md5 = Digest::MD5.hexdigest(val || "")
    self[:email] = val
  end

  def send_welcome_mail
    UserMailer.welcome(id).deliver_later
  end

  def send_new_password_mail
    send_reset_password_instructions
  end

  def user_column_count_left
    Setting.column_max_count.to_i - self.columns.size
  end

  def profile_url
    "/#{login}"
  end

  def github_url
    return "" if github.blank?
    "https://github.com/#{github.split("/").last}"
  end

  def website_url
    return "" if website.blank?
    website[%r{^https?://}] ? website : "http://#{website}"
  end

  def twitter_url
    return "" if twitter.blank?
    "https://twitter.com/#{twitter}"
  end

  def fullname
    return login if name.blank?
    "#{login} (#{name})"
  end

  def has_draft?
    !self.topics.where(draft: true).empty?
  end

  def draft_size
    self.topics.where(draft: true).size
  end

  def my_drafts
    self.topics.where(draft: true)
  end

  # 软删除
  def soft_delete
    self.state = "deleted"
    save(validate: false)
  end

  # @example.com 的可以修改邮件地址
  def email_locked?
    !legacy_omniauth_logined?
  end

  def calendar_data
    Rails.cache.fetch(["user", self.id, "calendar_data", Date.today, "by-months"]) do
      calendar_data_without_cache
    end
  end

  def calendar_data_without_cache
    date_from = 12.months.ago.beginning_of_month.to_date
    replies = self.replies.where("created_at > ?", date_from)
                  .group("date(created_at AT TIME ZONE 'CST')")
                  .select("date(created_at AT TIME ZONE 'CST') AS date, count(id) AS total_amount").all

    replies.each_with_object({}) do |reply, timestamps|
      timestamps[reply["date"].to_time.to_i.to_s] = reply["total_amount"]
    end
  end

  def team_options
    return @team_options if defined? @team_options
    teams = self.admin? ? Team.all : self.teams
    @team_options = teams.collect { |t| [t.name, t.id] }
  end

  # for Searchable
  def as_indexed_json
    {
      title: fullname,
    }.as_json
  end

  def indexed_changed?
    %i[login name].each do |key|
      return true if saved_change_to_attribute?(key)
    end
    false
  end
end
