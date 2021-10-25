module Admin
  class CreditRecordsController < Admin::ApplicationController
    def index
      @credit_records = CreditRecord.ransack(
        model_type_eq: params[:model_type_eq],
        model_id_eq: params[:model_id_eq],
        category_eq: params[:category_eq],
        num_gteq: params[:num_gteq],
        num_lteq: params[:num_lteq],
        user_login_eq: params[:user_login_eq],
        user_email_eq: params[:user_email_eq],
        created_at_gteq: params[:created_at_gteq],
        created_at_lteq: params[:created_at_lteq],
      ).result

      @credit_records = @credit_records.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    end
    def new
      @credit_record = CreditRecord.new
    end

    def create
      user_email = params[:credit_record][:user_email]
      user = User.find_by_email(user_email)

      if user.nil?
        return redirect_to new_admin_credit_record_path, alert: "用户不存在"
      end

      @credit_record = user.credit_operate(
        category: "admin_add_credit_record",
        reason: params[:credit_record][:reason],
        num: params[:credit_record][:num],
        operator: user.id,
        model_id: current_user.id,
        model_type: "User",
        meta: {
        }
      )
      redirect_to admin_credit_records_path(user_email_eq: user.email), notice: "添加成功"

    end
  end


end