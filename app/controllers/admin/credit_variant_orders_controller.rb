module Admin
  class CreditVariantOrdersController < Admin::ApplicationController
    before_action :set_credit_variant_order, only: [:show, :edit, :update, :authen, :ship, :complete, :revoke]
    def index
      @credit_variant_orders = CreditVariantOrder.ransack(
        user_login_eq: params[:user_login_eq],
        user_email_eq: params[:user_email_eq],
        credit_variant_sku_eq: params[:credit_variant_sku_eq],
        credit_product_category_eq: params[:credit_product_category_eq],
        deliver_no_start: params[:deliver_no],
        status_eq: params[:status_eq],
        created_at_gteq: params[:created_at_gteq],
        created_at_lteq: params[:created_at_lteq],
        uuid_eq: params[:uuid_eq],

        credit_product_uuid_eq: params[:credit_product_uuid_eq],
      ).result
      @credit_variant_orders = @credit_variant_orders.order(:created_at => :desc).page(params[:page])
    end

    def show
    end

    def revoke
      @credit_variant_order.do_revoke_operation current_user
      redirect_to [:admin, @credit_variant_order], notice: '已驳回此订单， 并返还积分给用户'
    end

    def authen
      @credit_variant_order.authen! current_user
      redirect_to [:admin, @credit_variant_order], notice: '认证成功'
    end

    def ship
      @credit_variant_order.deliver_no = params[:credit_variant_order][:deliver_no]
      @credit_variant_order.deliver_category = params[:credit_variant_order][:deliver_category]
      @credit_variant_order.virtual_markup = params[:credit_variant_order][:virtual_markup]
      @credit_variant_order.ship!
      redirect_to [:admin, @credit_variant_order], notice: '修改状态成功'
    end

    def complete
      @credit_variant_order.complete!
      redirect_to [:admin, @credit_variant_order], notice: '操作成功'
    end


    private

    def set_credit_variant_order
      @credit_variant_order = CreditVariantOrder.find_by_uuid(params[:id])
      @credit_variant_order ||= CreditVariantOrder.find(params[:id])
    end
  end
end