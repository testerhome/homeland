class Ad < ApplicationRecord
  mount_uploader :cover, PhotoUploader
  validates :topic_id, uniqueness: true
  validates :cover, :topic_id, presence: true
end
