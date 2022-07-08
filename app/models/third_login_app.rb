class ThirdLoginApp < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  before_create :generate_token

  private

  def generate_token
    self.api_token ||= SecureRandom.hex
  end
end
