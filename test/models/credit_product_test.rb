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
require "test_helper"

class CreditProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
