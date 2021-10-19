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
require "test_helper"

class CreditVariantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
