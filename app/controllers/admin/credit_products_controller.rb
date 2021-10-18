# frozen_string_literal: true

module Admin
  class CreditProductsController < Admin::ApplicationController
    before_action :set_credit_product, only: [:show, :edit, :update, :destroy, :add_sku]

    def index
      @credit_products = CreditProduct.all
    end

    def new
      @credit_product = CreditProduct.new

    end

    def edit
    end

    def show
    end

    def update
      @credit_product.credit_variants.map {|v| v.credit_product = @credit_product}
      if @credit_product.update(credit_product_params)
        redirect_to admin_credit_products_path, notice: "更新成功"
      else
        render action: "edit"
      end
    end

    def add_sku
    end

    def create
      @credit_product = CreditProduct.new(credit_product_params)
      @credit_product.credit_variants.map {|v| v.credit_product = @credit_product}

      if @credit_product.save
        redirect_to admin_credit_products_path, notice: '创建商品完毕'
      else
        render :new
      end
    end

    def destroy
    end

    protected

    def set_credit_product
      @credit_product = CreditProduct.find(params[:id])
    end

    def credit_product_params
      params.require(:credit_product).permit(:title, :description, :category, :main_image_url, :credit_variants_attributes => [:id, :sku, :title, :description, :credit_price, :stock, :_destroy])
    end
  end
end
