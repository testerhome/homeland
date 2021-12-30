# frozen_string_literal: true

class User
  # 用户权限相关
  module Roles
    extend ActiveSupport::Concern

    MIN_STATE_FOR_PUBLIC_MEMBER = 120
    MAX_STATE_FOR_PUBLIC_MEMBER = 129
    MIN_STATE_FOR_ENTERPRISE = 130
    MAX_STATE_FOR_ENTERPRISE = 140

    included do
      attr_accessor :category # 用来存储权限的大类, 临时存储
      enum state: {
        deleted: -1,
        member: 1,  # 对应个人普通用户
        blocked: 2,
        vip: 3, # 对应个人高级用户
        hr: 4,
        person_year_fee: 14, # 个人年费会员
        maintainer: 90, # 对应版主
        admin: 99, # 对应管理员

        # 注意， 公众号等权限为 120 到 140 之间
        public_simple: 120, # 公众普通账号
        public_flow: 121, # 公众倒流账号
        public_cooperation: 122, # 公众合作账号

        public_person_simple: 125, # 个人普通账号
        public_person_flow: 126, # 个人倒流账号
        public_person_cooperation: 127, # 个人合作账号

        enterprise_non_subscriber: 130, # 企业非签约号
        enterprise_subscriber: 131 # 企业签约号, 注意， 企业号权限编号最大不能超过MAX_STATE_FOR_ENTERPRISE
      }

      def fetch_role_category
        case state_before_type_cast
        when -1..99
          return '-1--99'
        when 120..129
          return '120--129'
        when 130..139
          return '130--139'
        else
          raise "新的权限没有包含进来"
        end
      end

      # user.admin?
      define_method :admin? do
        self.state.to_s == "admin" || Setting.admin_emails.include?(self.email)
      end
    end

    # 是否有 Wiki 维护权限
    def wiki_editor?
      self.admin? || self.maintainer? || self.vip?
    end

    # 是否可以发专栏
    def column_editor?
      # 开关为关时，不能发专栏
      return false if Setting.column_enabled.blank?
      # 只有白名单用户可以发专栏
      return false if Setting.column_user_white_list.nil?
      if Setting.column_user_white_list.split(Setting::SEPARATOR_REGEXP).include? login
        true
      end
    end

    # 回帖大于 150 的才有酷站的发布权限
    def site_editor?
      self.admin? || self.maintainer? || replies_count >= 100
    end

    def time_limit?
      t = Setting.newbie_limit_time.to_i
      return false if t == 0
      created_at > t.seconds.ago
    end

    def have_not_bind_wechat?
      !self.bind?('wechat')
    end

    # 是否能发帖
    def newbie?

      return false if %w[vip hr admin public_simple public_cooperation enterprise_subscriber].include?(self.state)
      return true unless self.audit_approved?
      time_limit? || have_not_bind_wechat? || legacy_omniauth_logined? || !certified?
    end

    # used in Plugin
    def roles?(role)
      case role
      when :wiki_editor then wiki_editor?
      when :site_editor then site_editor?
      else
        self.state.to_s == role.to_s
      end
    end

    # 是否可以编辑帖子
    def editor?
      return false if Setting.editor.nil?
      if Setting.editor.split(Setting::SEPARATOR_REGEXP).include? login
        true
      else
        false
      end
    end



    # 用户的账号类型
    def level
      return "newbie" if self.newbie?
      self.state
    end

    def level_name
      I18n.t("activerecord.enums.user.state.#{self.level}")
    end

    def level_color
      I18n.t("activerecord.enums.user.state_color.#{self.level}")
    end
  end
end
