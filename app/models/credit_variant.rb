class CreditVariant < ApplicationRecord
  belongs_to :credit_product
  validates_uniqueness_of :sku

  acts_as_list scope: :credit_product
end
