module Homeland::Activities
  class Event < ApplicationRecord
    validates :title, presence: true, length: {maximum: 60}
    validates :category, presence: true
    validates :photo_url, presence: true
    validates :start_at, presence: true
    validates :end_at, presence: true
    validates :registration_open_at, presence: true
    validates :registration_end_at, presence: true
    validates :description, presence: true
    validates :register_category_info,presence: true, length: {maximum: 64}

    validate :check_operator_info # 处理 step 2的问题
    validates_inclusion_of :status, in: %w(init waitting_audit success failure), message: "状态错误"

    store_accessor :operator_info, :host_name, :host_url, :cooperators


    validate :time_check
    validate :step_1_check
    belongs_to :user, class_name: "::User"
    has_many :comments, as: :commentable

    before_save :clean_empty_cooperators


    scope :pinned, -> { where("suggested_at is not null").order("suggested_at desc").limit(5) }
    scope :allowed, -> { where("status = ? ", 'success')}
    scope :incoming_events, -> { where("end_at >= ? ", Time.current.at_beginning_of_day).order("end_at asc")}
    scope :old_events, -> { where("end_at < ? ", Time.current.at_beginning_of_day).order("end_at asc")}
    # Ex:- scope :active, -> {where(:active => true)}

    protected

    def check_operator_info
      if self.status_changed? && self.status_was == "edit_operator"
      end
    end

    def sync_to_topic
      node = Node.find_by_name("活动沙龙")
      Topic.create(draft: false, title: self.title, body: self.description, node_id: node.id, user_id: self.user_id)
    end


    def time_check

      if start_at.present? && end_at.present?
        errors.add(:end_at, "结束时间须大于开始") if end_at < start_at
      end

      if registration_open_at.present? && registration_end_at.present?
        errors.add(:registration_end_at, "报名结束时间须大于开始") if registration_end_at < registration_open_at
      end
    end

    def step_1_check
      if status == "waitting_audit"
        errors.add(:host_name, "不能为空") if host_name.blank?

        %w[host_name realname email phone wechat_or_qq].each do |key|
          errors.add(key.to_sym, "不能为空") if send(key).blank?
        end
      end
    end

    def clean_empty_cooperators
      return if cooperators.blank?

      self.cooperators = cooperators.reject { |c| c.dig("name").blank? }
    end

  end


end