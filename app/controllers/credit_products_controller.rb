class CreditProductsController < ApplicationController
  before_action :find_credit_product, only: [:show]
  def index
    @credit_products = CreditProduct.all.online
  end

  def show
  end

  protected

  def find_credit_product
    @credit_product = CreditProduct.find(params[:id])
  end
end