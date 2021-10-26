class CreditProductsController < ApplicationController
  before_action :find_credit_product, only: [:show]
  def index
    load_ads
    @credit_products = CreditProduct.all.online
  end

  def show
  end

  protected

  def load_ads
    @credit_products_top_ads = Setting.credit_products_top_ads.map do |item|
      key, value = item.split("$$$")
      {img_url: key, link: value}
    end
  end

  def find_credit_product
    @credit_product = CreditProduct.find(params[:id])
  end
end