# == Schema Information
#
# Table name: credit_records
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  category   :string
#  reason     :string
#  num        :integer
#  operator   :string
#  meta       :jsonb
#  markup     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  model_id   :integer
#  model_type :string
#  balance    :integer
#
class CreditRecord < ApplicationRecord
  attr_accessor :user_login
  belongs_to :user
end
