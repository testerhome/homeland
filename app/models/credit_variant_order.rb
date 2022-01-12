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
#  uuid                   :string
#
class CreditVariantOrder < ApplicationRecord
  include AASM
  validate :check_stock_variant, on: :create
  validate :check_user_credit_sum, on: :create
  validates_numericality_of :num, greater_than: 0
  belongs_to :credit_variant
  has_one :credit_product, through: :credit_variant

  belongs_to :user
  before_create :set_uuid
  delegate_missing_to :credit_variant
  # delegate_missing_to :credit_product, prefix: true

  aasm(:status) do
    state :waiting_authen, initial: true
    state :waiting_ship
    state :shipping
    state :completed
    state :canceled
    state :revoked
    state :dropped

    event :authen do
      transitions from: :waiting_authen, to: :waiting_ship,  after: Proc.new {|user| record_authen_user(user) }
    end

    event :ship do
      transitions from: [:shipping, :waiting_ship], to: :shipping
    end

    event :complete do
      transitions from: :shipping, to: :completed
    end

    event :cancel do
      transitions from: [:waiting_authen, :shipping], to: :canceled
    end

    event :revoke do
      transitions from: [:waiting_authen, :waiting_ship], to: :revoked
    end

    event :drop do
      transitions from: [:waiting_authen, :waiting_ship], to: :dropped
    end
  end

  def titles
    [credit_product.title, credit_variant.title]
  end

  def total_price
    self.num * self.credit_variant.credit_price
  end

  def do_revoke_operation(operator)
    return {code: 1,msg: "此时订单状态已经不允许驳回"} unless self.may_revoke?

    $lock_manager.lock!("credit_variant_#{credit_variant.id}", 2000) do |locked|
      self.class.transaction do

        self.revoke

        self.credit_variant.stock += self.num
        self.save!
        self.credit_variant.save!

        self.user.credit_operate(
          category: "order_revork",
          reason: "订单被驳回，返还积分 ",
          num: self.num * self.current_credit_price,
          operator: operator.id,
          model_id: id,
          model_type: "CreditVariantOrder",
          meta: {
          }
        )
      end
    end
  end

  protected

  def set_uuid
    self.uuid = SecureRandom.uuid
  end

  def check_stock_variant
    errors.add(:num, "库存不足") if self.credit_variant.stock < self.num
  end

  def check_user_credit_sum
    errors.add(:num, "积分不足") if self.credit_variant.credit_price.to_i * self.num > self.user.credit_sum.to_i
  end

  def record_authen_user(user)
    self.authen_user_id = user.id
  end

  class << self
    def buy(variant, num, user, deliver_address:, deliver_markup: "", deliver_receiver_name: "", deliver_receiver_phone: "")
      $lock_manager.lock!("credit_variant_#{variant.id}", 2000) do |locked|
        order = nil
        self.transaction do

          current_credit_price = variant.credit_price
          order = self.new(
            credit_variant: variant,
            num: num,
            current_credit_price: current_credit_price,
            user: user,
            deliver_address: deliver_address,
            deliver_markup: deliver_markup,
            deliver_receiver_name: deliver_receiver_name,
            deliver_receiver_phone: deliver_receiver_phone
          )
          order.save!

          variant.stock -= num
          variant.save!

          user.credit_operate(
            category: "buy_variant_order",
            reason: "兑换商品",
            num: num * current_credit_price * -1,
            operator: user.id,
            model_id: order.id,
            model_type: "CreditVariantOrder"
          )
        end
        return order
      end
    end
  end
end
