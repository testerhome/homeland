class CreditsController <  ApplicationController
  before_action :authenticate_user!

  def index
    @credit_records = current_user.credit_records.order(:updated_at => 'desc').page(params[:page]).per(10)
  end
end
