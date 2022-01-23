# frozen_string_literal: true

class User
  module CreditOperations
    extend ActiveSupport::Concern

    # t.bigint "user_id", null: false
    # t.string "category"
    # t.string "reason"
    # t.integer "num"
    # t.string "operator"
    # t.jsonb "meta"
    # t.string "markup"
    def credit_operate(attributes)
      attributes = attributes.with_indifferent_access
      num = attributes[:num].to_i
      credit_record = nil



      user = self
      $lock_manager.lock!("user-#{self.id}-credit-operations", 2000) do |locked|
      ActiveRecord::Base.transaction do
        # 注意， 此处要加锁
          current_sum = user.reload.credit_sum
          user.credit_sum = current_sum.to_i + num
          user.save!
          credit_record = CreditRecord.new(attributes)
          credit_record.user = user
          credit_record.balance = credit_sum
          credit_record.save!
          yield if block_given?
        end
      end
      credit_record
    end
  end
end