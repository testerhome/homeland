# frozen_string_literal: true

# RailsSettings Model
class Setting < RailsSettings::Base
  LEGECY_ENVS = {
    github_token: "github_api_key",
    github_secret: "github_api_secret",
  }

  concerning :Legacy do
    included do
    end

    class_methods do
      def legecy_env_instead(key)
        LEGECY_ENVS[key]
      end

      def legecy_envs
        keys = []
        LEGECY_ENVS.each_key do |key|
          keys << key if ENV[key.to_s].present?
        end
        keys
      end
    end
  end

  # List setting value separator chars
  SEPARATOR_REGEXP = /[\s,]/

  SYSTEM_KEYS = %w[require_restart doman https asset_host]

  # keys that allow update in admin
  HOT_UPDATE_KEYS = %w[
    default_locale
    auto_locale
    timezone
    admin_emails
    navbar_brand_html
    custom_head_html
    navbar_html
    footer_html
    index_html
    wiki_index_html
    wiki_sidebar_html
    site_index_html
    topic_index_sidebar_html
    topic_index_sidebar_important_ads_html
    after_topic_html
    before_topic_html
    node_ids_hide_in_topics_index
    reject_newbie_reply_in_the_evening
    night_curfew
    night_curfew_start
    night_curfew_end
    shutdown_register
    newbie_limit_time
    ban_words_on_reply
    ban_words_on_body
    new_from_github_notices
    newbie_notices
    new_tags
    tips
    apns_pem
    blacklist_ips
    ban_reason_html
    ban_reasons
    topic_create_limit_interval
    topic_create_hour_limit_count
    column_max_count
    column_user_white_list
    column_enabled
    before_wechat_html
    after_wechat_html
    editor
    article_node
    allow_change_login
    sign_up_daily_limit
    use_recaptcha
    recaptcha_key
    recaptcha_secret
    twitter_id
    share_allow_sites
    editor_languages
    sorted_plugins
    github_stats_repos
    certify_questions
    index_sidebar_top_html
    index_sidebar_bottom_html
    index_roll_card_html
    index_footer_card_html
    notification_sidebar_advertise
    invite_code_expired_in_seconds
    profile_fields
    google_analytics_key
    enable_register_answer_question_cerification
    enable_audit_topics_create
    enable_audit_replies_create
    enable_audit_users_create
    enable_audit_topic_update
    audit_topic_update_attributes
    enable_audit_reply_update
    audit_reply_update_attributes
    enable_audit_user_update
    audit_user_update_attributes
    search_need_login
    audit_user_whitelist
    column_channels_show_node_names
    geekbang_app_id
    geekbang_app_secret
  ]

  # = System
  field :require_restart, default: false, type: :boolean
  field :domain, default: (ENV["domain"] || "localhost"), readonly: true
  field :https, type: :boolean, default: (ENV["https"] || "true"), readonly: true
  field :asset_host, default: (ENV["asset_host"] || nil), readonly: true

  # = Basic
  field :app_name, default: (ENV["app_name"] || "Homeland")
  field :timezone, default: "UTC"
  # Module [topic,home,team,github,editor.code]
  field :modules, default: (ENV["modules"] || "all"), type: :array
  # Plugin sort
  field :sorted_plugins, default: [], type: :array, separator: /[\s,]+/
  # User profile module default: all [company,twitter,website,tagline,location,alipay,paypal,qq,weibo,wechat,douban,dingding,aliwangwang,facebook,instagram,dribbble,battle_tag,psn_id,steam_id]
  field :profile_fields, default: (ENV["profile_fields"] || "all"), type: :array

  # = Rack Attach
  field :rack_attack, type: :hash, default: {
                        limit: ENV["rack_attack.limit"] || 0,
                        period: ENV["rack_attack.period"] || 3.minutes,
                      }

  # = Uploader
  # can be  upyun/aliyun
  field :upload_provider, default: (ENV["upload_provider"] || "file"), readonly: true
  # access_id or upyun username
  field :upload_access_id, default: ENV["upload_access_id"], readonly: true
  # access_secret or upyun password
  field :upload_access_secret, default: ENV["upload_access_secret"], readonly: true
  field :upload_bucket, default: ENV["upload_bucket"], readonly: true
  field :upload_url, default: ENV["upload_url"], readonly: true
  field :upload_aliyun_internal, type: :boolean, default: (ENV["upload_aliyun_internal"] || "false"), readonly: true
  field :upload_aliyun_region, default: (ENV["upload_aliyun_region"] || ENV["upload_aliyun_area"]), readonly: true

  # = Mailer
  field :mailer_provider, default: (ENV["mailer_provider"] || "smtp"), readonly: true
  field :mailer_sender, default: (ENV["mailer_sender"] || "no-reply@localhost"), readonly: true
  field :mailer_options, type: :hash, readonly: true, default: {
                           api_key: (ENV["mailer_options_api_key"] || ENV["mailer_options.api_key"]),
                           address: (ENV["mailer_options_address"] || ENV["mailer_options.address"]),
                           port: (ENV["mailer_options_port"] || ENV["mailer_options.port"]),
                           domain: (ENV["mailer_options_domain"] || ENV["mailer_options.domain"]),
                           user_name: (ENV["mailer_options_user_name"] || ENV["mailer_options.user_name"]),
                           password: (ENV["mailer_options_password"] || ENV["mailer_options.password"]),
                           authentication: (ENV["mailer_options_authentication"] || ENV["mailer_options.authentication"] || "login"),
                           enable_starttls_auto: (ENV["mailer_options_enable_starttls_auto"] || ENV["mailer_options.enable_starttls_auto"]),
                         }

  # = SSO
  field :sso, type: :hash, readonly: true, default: {
                enable: (ENV["sso_enable"] || ENV["sso.enable"] || false),
                enable_provider: (ENV["sso_enable_provider"] || ENV["sso_enable.provider"] || false),
                url: (ENV["sso_url"] || ENV["sso.url"]),
                secret: (ENV["sso_secret"] || ENV["sso.secret"]),
              }

  field :github_stats_repos, default: "", type: :string
  field :new_from_github_notices, default: "", type: :string

  # = Omniauth API Keys
  field :github_api_key, default: (ENV["github_api_key"] || ENV["github_token"])
  field :github_api_secret, default: (ENV["github_api_secret"] || ENV["github_secret"])
  field :twitter_api_key, default: ENV["twitter_api_key"]
  field :twitter_api_secret, default: ENV["twitter_api_secret"]
  field :wechat_api_key, default: ENV["wechat_api_key"]
  field :wechat_api_secret, default: ENV["wechat_api_secret"]

  # = Other Site Configs
  field :admin_emails, type: :array, default: (ENV["admin_emails"] || "admin@admin.com"), separator: /[\s,]+/

  field :newbie_limit_time, type: :integer, default: 0
  field :topic_create_limit_interval, type: :integer, default: 0
  field :topic_create_hour_limit_count, type: :integer, default: 0
  field :sign_up_daily_limit, type: :integer, default: 0
  field :invite_code_expired_in_seconds, type: :integer, default: 300

  field :reject_newbie_reply_in_the_evening, default: "false", type: :boolean
  field :night_curfew, default: "false", type: :boolean
  field :night_curfew_start, default: 23, type: :integer
  field :night_curfew_end, default: 8, type: :integer
  field :shutdown_register, default: "false", type: :boolean
  field :allow_change_login, type: :boolean, default: (ENV["allow_change_login"] || false)
  field :topic_create_rate_limit, default: "false", type: :boolean
  field :node_ids_hide_in_topics_index, type: :array, default: []

  # 积分相关权限
  field :tech_node_ids, type: :array, default: []
  field :tech_topic_created_credit, type: :integer, default: 100
  field :question_created_credit, type: :integer, default: 10
  field :excellent_topic_credit, type: :integer, default: 500
  field :topic_user_reply_reward_credit, type: :integer, default: 5
  field :topic_reply_credit, type: :integer, default: 2
  field :topic_reply_credit_limit, type: :integer, default: 20
  field :topic_like_credit, type: :integer, default: 2
  field :reply_like_credit, type: :integer, default: 2
  field :question_best_answer_credit, type: :integer, default: 100
  field :invite_code_registered_credit, type: :integer, default: 50
  field :login_credit, type: :integer, default: 1
  field :registered_credit, type: :integer, default: 500

  field :credit_products_top_ads, type: :array, default: []

  field :apns_pem, default: ""
  field :blacklist_ips, default: [], type: :array

  field :twitter_id
  field :share_allow_sites, default: %w[twitter weibo facebook wechat], type: :array, separator: /[\s]+/

  # = UI custom html
  field :navbar_brand_html, default: -> { %(<a href="/" class="navbar-brand"><b>#{self.app_name}</b></a>) }
  field :default_locale, default: "zh-CN"
  field :auto_locale, default: "false", type: :boolean
  field :custom_head_html, default: ""
  field :navbar_html, default: ""
  field :footer_html, default: ""
  field :index_sidebar_top_html, default: ""
  field :notification_sidebar_advertise, default: ""
  field :topic_index_sidebar_important_ads_html, default: ""
  field :index_sidebar_bottom_html, default: ""
  field :index_roll_card_html, default: ""
  field :index_footer_card_html, default: ""
  field :index_html, default: ""
  field :wiki_index_html, default: ""
  field :wiki_sidebar_html, default: ""
  field :site_index_html, default: ""
  field :topic_index_sidebar_html, default: ""
  field :before_topic_html, default: ""
  field :after_topic_html, default: ""
  field :topic_index_sidebar_html, default: ""
  field :ban_reasons, default: "标题或正文描述不清楚", type: :array, separator: /[\n]+/
  field :ban_reason_html, default: "此贴因内容原因不符合要求，被管理员屏蔽，请根据管理员给出的原因进行调整"
  field :ban_words_on_reply, default: [], type: :array, separator: /[\n]+/
  field :ban_words_on_body, default: [], type: :array, separator: /[\n]+/
  field :newbie_notices, default: ""
  field :new_tags, default: "", type: :string
  field :tips, default: [], type: :array, separator: /[\n]+/
  field :editor_languages, default: %w[rb go js py java rs php css html yml json xml], type: :array, separator: /[\s,]+/

  # = Column
  field :column_max_count, default: 2, type: :integer
  field :column_enabled, default: false, type: :string
  field :column_user_white_list, default: [], separator: SEPARATOR_REGEXP
  field :editor, default: [], separator: SEPARATOR_REGEXP
  field :article_node, default: 1, type: :integer
  field :before_wechat_html, type: :string
  field :after_wechat_html, type: :string

  # = Column Channels
  field :column_channel_top_ads, type: :array, default: []
  field :column_channel_top_raw_html, type: :string

  field :column_channel_right_ads, type: :array, default: []
  field :column_channel_right_raw_html, type: :string

  field :column_channel_public_enterprise_column_ids, type: :array, default: []
  field :column_channel_simple_column_ids, type: :array, default: []

  field :enable_register_answer_question_cerification, type: :boolean, default: "false"

  field :enable_audit_topics_create, type: :boolean, default: false
  field :enable_audit_replies_create, type: :boolean, default: false
  field :enable_audit_users_create, type: :boolean, default: false

  field :enable_audit_topic_update, type: :boolean, default: false
  field :enable_audit_reply_update, type: :boolean, default: false
  field :enable_audit_user_update, type: :boolean, default: false

  field :audit_topic_update_attributes, type: :array, default: ["title", "body"]
  field :audit_reply_update_attributes, type: :array, default: ["body"]
  field :audit_user_update_attributes, type: :array, default: ["name"]

  field :audit_user_whitelist, type: :array, default: []

  field :search_need_login, type: :boolean, default: true

  field :column_channels_show_node_names, type: :array, default: %w[研发效能 测试技术&方案 测试基础&方法 专题测试 职业发展 社区活动]

  # = ReCaptcha
  field :use_recaptcha, default: false, type: :boolean
  # default key for development env
  field :recaptcha_key, default: "6Lcalg8TAAAAAFhLrcbC4QmxNuseboteXxP3wLxI"
  field :recaptcha_secret, default: "6Lcalg8TAAAAAN-nZr547ORtmtpw78mTLWtVWFW2"
  field :google_analytics_key, default: ""
  field :certify_questions, default: "", type: :string

  # sendcloud

  field :sendcloud_sms_template_id, default: ""
  field :sendcloud_key, default: ""
  field :sendcloud_user, default: ""

  field :phone_verify_code_to_all, type: :string, default: ""

  # geekbang

  field :geekbang_app_id, default: ""
  field :geekbang_app_secret, default: ""

  # static node
  field :node_ban_id, default: 55, type: :integer
  field :node_bugs_id, default: 47, type: :integer
  field :node_opencourse_id, default: 67, type: :integer
  field :node_questions_id, default: 20, type: :integer
  field :node_job_id, default: 19, type: :integer

  class << self
    def editable_keys
      HOT_UPDATE_KEYS
    end

    def ban_reason_list
      self.ban_reasons
    end

    def has_admin?(email)
      return false if self.admin_emails.blank?
      self.admin_emails.split(SEPARATOR_REGEXP).include?(email)
    end

    def admin_email_list
      self.admin_emails.split(SEPARATOR_REGEXP)
    end

    def protocol
      self.https? ? "https" : "http"
    end

    def base_url
      return "http://localhost:3000" if Rails.env.development?
      [self.protocol, self.domain].join("://")
    end

    def has_module?(name)
      return true if self.modules.blank? || self.modules.include?("all")
      self.modules.map { |str| str.strip }.include?(name.to_s)
    end

    def github_stats_repos_list
      # 去掉其中空字符串的元素
      self.github_stats_repos.split(SEPARATOR_REGEXP).select { |urls| urls != "" }
    end

    def has_omniauth?(provider)
      case provider.to_s
      when "github"
        self.github_api_key.present?
      when "twitter"
        self.twitter_api_key.present?
      when "wechat"
        self.wechat_api_key.present?
      else
        false
      end
    end

    def has_profile_field?(name)
      return true if self.profile_fields.blank? || self.profile_fields.include?("all")
      self.profile_fields.map { |str| str.strip }.include?(name.to_s)
    end

    def sso_enabled?
      return false if self.sso_provider_enabled?
      self.sso[:enable] == true
    end

    def sso_provider_enabled?
      self.sso[:enable_provider] == true
    end

    def certify_questions_list
      self.certify_questions.split("\n")
    end

    def rails_initialized?
      true
    end

    # https://regex101.com/r/m1UOqT/1
    def cable_allowed_request_origin
      /http(s)?:\/\/#{Setting.domain}(:\d+)?/
    end

    def is_night_curfew?
      if self.night_curfew?
        return Time.zone.now.hour >= Setting.night_curfew_start.to_i || Time.zone.now.hour <= Setting.night_curfew_end.to_i
      else
        return false
      end
    end
  end

  def require_restart?
    !HOT_UPDATE_KEYS.include?(self.var)
  end

  def type
    @option ||= self.class.get_field(self.var)
    @option[:type]
  end
end
