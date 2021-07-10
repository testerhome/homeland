# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :require_no_sso!, only: %i[new create]

  # POST /resource
  def create

    if Setting.shutdown_register?
      message = "社区关闭注册，如需注册请联系社区公众号！"
      logger.warn message
      return render status: 403, plain: message
    end

    cache_key = ["user-sign-up", request.remote_ip, Date.today]
    # IP limit
    sign_up_count = Rails.cache.read(cache_key) || 0
    setting_limit = Setting.sign_up_daily_limit
    if setting_limit > 0 && sign_up_count >= setting_limit
      message = "You not allow to sign up new Account, because your IP #{request.remote_ip} has over #{setting_limit} times in today."
      logger.warn message
      return render status: 403, plain: message
    end

    build_resource(sign_up_params)

    invite_flag = false
    if sign_up_params["invite_code"].blank?
      resource.errors.add(:base, t("invite_code.empty"))
      invite_flag = true
    else
      invite_code = InviteCode.find_by_code sign_up_params["invite_code"]
      if invite_code.blank?
        resource.errors.add(:base, t("invite_code.not_exist"))
        invite_flag = true
      elsif invite_code.expired?
        resource.errors.add(:base, t("invite_code.expired"))
        invite_flag = true
      elsif invite_code.consumed?
        resource.errors.add(:base, t("invite_code.consumed"))
        invite_flag = true
      end
    end

    if invite_flag
      Rails.cache.write(cache_key, sign_up_count + 1)
      clean_up_passwords resource
      respond_with resource
      return
    end

    unless verify_complex_captcha?(resource)
      Rails.cache.write(cache_key, sign_up_count + 1)
      clean_up_passwords resource
      respond_with resource
      return
    end

    if not User.find_by_unconfirmed_email(sign_up_params["email"]).blank?
      resource.errors.add(:base, "Email 激活中，请不要重复注册，查看邮箱，进行激活！")
      Rails.cache.write(cache_key, sign_up_count + 1)
      clean_up_passwords resource
      respond_with resource
      return
    end

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource_class == User
        invite_code = InviteCode.find_by_code sign_up_params["invite_code"]
        r_user = User.find_by_login sign_up_params["login"]
        invite_code.consumer_id = r_user.id
        invite_code.save!
      end

      session[:omniauth] = nil
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def after_inactive_sign_up_path_for(resource_or_scope)
    new_user_session_path
  end
end
