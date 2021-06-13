class InviteCode < ApplicationRecord

    belongs_to :creater, class_name: "User", required: true

    validate :user_quota, :on => :create

    def expired?
        created_at < Setting.invite_code_expired_in_seconds.seconds.ago
    end

    def consumed?
        self.consumer_id?
    end

    private

    def today
        where(:created_at => (Time.zone.now.beginning_of_day..Time.zone.now))
    end

    def this_week
        where(:created_at => (Time.zone.now.beginning_of_week..Time.zone.now))
    end

    def user_quota
        if creater.invite_codes.where(:created_at => (Time.zone.now.beginning_of_day..Time.zone.now)).count >= 2
            errors.add(:base, "超过每天的邀请码限额！")
        elsif creater.invite_codes.where(:created_at => (Time.zone.now.beginning_of_week..Time.zone.now)).count >= 14
            errors.add(:base, "超过每周的邀请码限额！")
        end
    end
end
