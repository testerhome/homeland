# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include Wisper::Publisher # 加入监听器
  before_action :require_no_sso!, only: %i[new create]

  def create
    resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?

    if session[:omniauth]
      @auth = Authorization.find_or_create_by!(provider: session[:omniauth]["provider"], uid: session[:omniauth]["uid"], user_id: resource.id)
      if @auth.blank?
        redirect_to new_user_session_path, alert: "Sign in and bind OAuth account failed."
        return
      end

      set_flash_message(:notice, :signed_in_bind_oauth)
      session[:omniauth] = nil
    end
    sign_in(resource_name, resource)
    broadcast(:user_login, resource)
    yield resource if block_given?
    respond_to do |format|
      format.html { redirect_back_or_default(root_url) }
      format.json { render status: "201", json: resource.as_json(only: %i[login email]) }
    end
  end
end
