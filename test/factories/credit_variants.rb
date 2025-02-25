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
FactoryBot.define do
  factory :credit_variant do
    sku { "MyString" }
    references { "" }
    credit_price { "9.99" }
  end
end
