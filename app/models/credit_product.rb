class CreditProduct < ApplicationRecord
  has_many :credit_variants, -> {order(position: :asc)}
  acts_as_list

  accepts_nested_attributes_for :credit_variants, allow_destroy: true, reject_if: proc { |attributes|
    attributes['sku'].blank?
  }
end
