module Admin
  class CreditVariantsController < Admin::ApplicationController
    def index
      @credit_variants = CreditVariant.all
    end
  end
end