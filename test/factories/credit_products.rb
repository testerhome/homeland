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
FactoryBot.define do
  factory :credit_product do
    title { "MyString" }
    main_image_url { "MyString" }
    category { "MyString" }
    description { "MyString" }
    state { "MyString" }
  end
end
