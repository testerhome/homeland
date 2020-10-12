# frozen_string_literal: true

class AdminPhoto < Photo
  belongs_to :user, optional: true

  validates_presence_of :image

  # 封面图
  mount_uploader :image, AdminPhotoUploader
end
