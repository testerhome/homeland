module Admin
  class ThirdLoginAppsController < Admin::ApplicationController
    before_action :set_third_login_app, only: [:destroy]

    def index
      @third_login_apps = ThirdLoginApp.all
    end

    def new
      @third_login_app = ThirdLoginApp.new
    end

    def create
      @third_login_app = ThirdLoginApp.new(third_login_app_params)

      if @third_login_app.save
        redirect_to admin_third_login_apps_path, notice: "创建成功"
      else
        render :new
      end
    end

    def destroy
      @third_login_app.destroy
      redirect_to admin_third_login_apps_path, notice: "删除成功"
    end

    private

    def third_login_app_params
      params.require(:third_login_app).permit(:name, :description, :login_url)
    end

    def set_third_login_app
      @third_login_app = ThirdLoginApp.find(params[:id])
    end
  end
end
