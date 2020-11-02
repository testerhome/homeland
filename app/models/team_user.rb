# frozen_string_literal: true

class TeamUser < ApplicationRecord
  enum role: %i[owner member]
  enum status: %i[pendding accepted pendding_owner_approved]

  belongs_to :team, touch: true, counter_cache: true
  belongs_to :user

  validates :login, :team_id, :role, presence: true, on: :invite
  validates :user_id, uniqueness: { scope: :team_id, message: I18n.t("teams.user_existed") }

  attr_accessor :login
  attr_accessor :actor_ids

  before_validation do
    if login.present?
      u = User.find_by_login(login)
      self.errors.add(:login, :notfound) if u.blank?
      self.user_id = u&.id
    end
  end
  after_create_commit :notify_user_to_accept

  def actor_ids
    @actor_ids || []
  end

  def status_name
    I18n.t("team_user_status.#{self.status}")
  end

  def role_name
    I18n.t("team_user_role.#{self.role}")
  end

  def notify_user_to_accept
    return unless self.pendding? || self.pendding_owner_approved?
    if self.pendding?
      self.actor_ids.each do |actor_id|
        Notification.create notify_type: "team_invite",
                            actor_id: actor_id,
                            user_id: self.user_id,
                            target: self,
                            second_target: team
      end
    end
    if self.pendding_owner_approved?
      self.actor_ids.each do |actor_id|
        Notification.create notify_type: "team_join",
                            actor_id: actor_id,
                            user_id: actor_id,
                            target: self,
                            second_target: team
      end
    end
  end

  def reject_user_join(message)
    self.actor_ids.each do |actor_id|
      Notification.create notify_type: "reject_user_join",
                          actor_id: actor_id,
                          user_id: self.user_id,
                          target: self,
                          second_target: team,
                          message: message
    end
    self.destroy
  end
end
