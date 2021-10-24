# == Schema Information
#
# Table name: credit_variants
#
#  id                :bigint           not null, primary key
#  sku               :string
#  image_url         :string
#  title             :string
#  description       :string
#  credit_product_id :bigint
#  credit_price      :decimal(8, 2)    default(0.0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  stock             :integer
#  position          :integer
#  online            :boolean          default(TRUE)
#
class CreditVariant < ApplicationRecord

  belongs_to :credit_product
  validates_uniqueness_of :sku
  validates_numericality_of :stock, greater_than_or_equal_to: 0
  validates_numericality_of :credit_price, greater_than_or_equal_to: 0

  acts_as_list scope: :credit_product

  has_many :credit_variant_orders

  delegate_missing_to :credit_product

end
