# == Schema Information
#
# Table name: credit_variant_orders
#
#  id                     :bigint           not null, primary key
#  credit_variant_id      :bigint           not null
#  num                    :integer
#  online                 :boolean          default(FALSE)
#  status                 :string
#  user_id                :bigint           not null
#  deliver_address        :string
#  deliver_category       :string
#  deliver_markup         :string
#  deliver_no             :string
#  deliver_receiver_name  :string
#  deliver_receiver_phone :string
#  current_credit_price   :decimal(, )
#  authen_user_id         :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
FactoryBot.define do
  factory :credit_variant_order do
    credit_variant { nil }
    num { 1 }
    status { "MyString" }
    user { nil }
    deliver_address { "MyString" }
    deliver_no { "MyString" }
    deliver_receiver_name { "MyString" }
    deliver_receiver_phone { "MyString" }
    current_credit_price { "9.99" }
  end
end
