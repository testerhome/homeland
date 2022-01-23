class CreditVariantOrdersController < ApplicationController
  before_action :authenticate_user!, only: [:create, :new]
  def index
    @credit_variant_orders = current_user.credit_variant_orders.order(:created_at => :desc)
  end

  def new
    @credit_variant = CreditVariant.find_by_id(params[:credit_variant_id])
    return redirect_to credit_products_path unless @credit_variant
    @num = params[:num].to_i

    last_order = current_user.credit_variant_orders.order(:created_at => :desc).first || CreditVariantOrder.new

    @credit_variant_order = CreditVariantOrder.new(
      credit_variant: @credit_variant,
      num: @num,
      deliver_receiver_name: last_order.deliver_address,
      deliver_receiver_name: last_order.deliver_receiver_name,
      deliver_receiver_phone: last_order.deliver_receiver_phone

      )
  end

  def show
    @credit_variant_order = CreditVariantOrder.where(user: current_user).find(params[:id])
  end

  def create
    @credit_variant = CreditVariant.find(params[:credit_variant_order][:credit_variant_id])
    @num = params[:credit_variant_order][:num].to_i
    @credit_variant_order = CreditVariantOrder.buy(@credit_variant, @num, current_user,
      deliver_receiver_name: params[:credit_variant_order][:deliver_receiver_name],
      deliver_address: params[:credit_variant_order][:deliver_address],
      deliver_receiver_phone: params[:credit_variant_order][:deliver_receiver_phone],
      deliver_markup: params[:credit_variant_order][:deliver_markup]

    )

    if @credit_variant_order.errors.count > 0
      render :new
    else
      redirect_to credit_variant_order_path(@credit_variant_order), notice: '购买成功'
    end
  end

  private

  def set_credit_variant_order

  end

end
