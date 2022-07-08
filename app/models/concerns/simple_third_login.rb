module SimpleThirdLogin
  extend ActiveSupport::Concern

  def fetch_third_ticket
    self.third_ticket = generate_third_ticket
    generate_third_unique_id_if_necessary!

    Rails.cache.fetch("third_login_app_#{self.third_ticket}", expires_in: 5.minutes) do
      self.id.to_s
    end

    self.third_ticket
  end

  def generate_third_unique_id_if_necessary!
    if self.third_unique_id.blank?
      self.third_unique_id = SecureRandom.hex
      self.save!
    end
  end

  included do
    attr_accessor :third_ticket
  end

  class_methods do
    def find_from_third_unique_id(third_unique_id)
      self.find_by(third_unique_id: third_unique_id)
    end

    def find_by_third_ticket(ticket, third_app_name, third_app_api_token)
      return nil unless ticket.match?(/\A[0-9a-f]{32}\z/)
      return nil if ThirdLoginApp.find_by(name: third_app_name, api_token: third_app_api_token).nil?

      id = Rails.cache.read("third_login_app_#{ticket}")
      return nil unless id.present?

      User.find_by_id id
    end
  end

  private

  def generate_third_ticket
    Rails.cache.fetch("third_login_app_user_#{id}", expires_in: 5.minutes) do
      SecureRandom.hex
    end
  end
end
