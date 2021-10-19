# == Schema Information
#
# Table name: credit_products
#
#  id             :bigint           not null, primary key
#  title          :string
#  main_image_url :string
#  category       :string
#  description    :string
#  state          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  position       :integer
#  online         :boolean          default(TRUE)
#
class CreditProduct < ApplicationRecord
  has_many :credit_variants, -> {order(position: :asc)}
  acts_as_list

  scope :online, -> { where(online: true) }

  accepts_nested_attributes_for :credit_variants, allow_destroy: true, reject_if: proc { |attributes|
    attributes['sku'].blank?
  }
end
