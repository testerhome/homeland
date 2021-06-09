class InviteCodesController <  ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user!
    respond_to :js, :html, only: [:destroy]

    def index
        @codes = InviteCode.where(creater_id: current_user.id).recent.page(params[:page])
    end

    def create
        @code = InviteCode.new
        @code.code = SecureRandom.uuid
        @code.creater_id = current_user.id
        @code.expired_in = Setting.invite_code_expired_in_seconds
        if @code.save
            redirect_to(invite_codes_path, notice: "创建成功")
        else
            redirect_to(invite_codes_path, notice: "创建失败")
        end
    end

    def destroy
        @code = InviteCode.find(params[:id])
        @code.destroy
        respond_with do |format|
            format.html { redirect_to invite_codes_path }
            format.js { render layout: false }
        end
    end

end