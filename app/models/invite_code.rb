class InviteCode < ApplicationRecord
    def expired?
        created_at < Setting.invite_code_expired_in_seconds.seconds.ago
    end

    def consumed?
        self.consumer_id?
    end
end
