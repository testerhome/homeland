class CreditVariantOrdersController < ApplicationController
  before_action :authenticate_user!, only: [:create, :new]
  def index
    @credit_variant_orders = current_user.credit_variant_orders.order(:created_at => :desc)
  end

  def new
    @credit_variant = CreditVariant.find_by_id(params[:credit_variant_id])
    return redirect_to credit_products_path unless @credit_variant
    @num = params[:num].to_i
    @credit_variant_order = CreditVariantOrder.new(credit_variant: @credit_variant, num: @num)
  end

  def show
    @credit_variant_order = CreditVariantOrder.where(user: current_user).find(params[:id])
  end

  def create
    @credit_variant = CreditVariant.find(params[:credit_variant_order][:credit_variant_id])
    @num = params[:credit_variant_order][:num].to_i
    @credit_variant_order = CreditVariantOrder.buy(@credit_variant, @num, current_user, {})

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
