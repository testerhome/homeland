# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
  end

  def account
  end

  def edit_phone
  end

  def update_phone
    phone_number = params[:user][:phone_number]
    phone_code = params[:user][:phone_code]

    real_code = Rails.cache.read("phone_code_#{phone_number}")


    if real_code.present? &&  phone_code.to_s == real_code.to_s && phone_number.present?
      current_user.update(phone_number: phone_number)
      redirect_to topics_path, notice: "手机号码更新成功"
    else
      redirect_to edit_phone_setting_path, notice: "验证码错误"
    end
  end

  def profile
  end

  def password
    render_404 if Setting.sso_enabled?
  end

  def reward
  end

  def update
    case params[:by]
    when "password"
      update_password
    when "profile"
      update_profile
    when "reward"
      update_reward
    else
      update_basic
    end
  end

  def destroy
    current_password = params[:user][:current_password]

    unless @user.valid_password?(current_password)
      @user.errors.add(:current_password, :invalid)
      render "show"
      return
    end

    @user.soft_delete
    sign_out
    redirect_to root_path, notice: "账号删除成功。"
  end

  def auth_unbind
    provider = params[:provider]

    if current_user.legacy_omniauth_logined?
      redirect_to account_setting_path, alert: "账户三方账号登录且未设置 Email 和密码，不允许解绑，请设置密码，并修改 Email。"
      return
    end

    current_user.authorizations.where(provider: provider).delete_all
    redirect_to account_setting_path, notice: t("users.unbind_success", provider: provider.titleize)
  end

  private

    def set_user
      @user = current_user
    end

    def user_params
      attrs = User::ACCESSABLE_ATTRS.dup
      if Setting.allow_change_login?
        attrs << :login
      end

      if !current_user.email_locked?
        attrs << :email
      end
      params.require(:user).permit(*attrs)
    end

    def update_basic
      email_ori = @user.email
      email_change = params[:user][:email]
      if not email_change.blank? and email_ori != email_change and email_change.include?("@example.com")
        @user.errors.add(:email, "不能使用 example.com 后缀的邮箱")
        render "show"
        return
      end
      if @user.update(user_params)
        theme = params[:user][:theme]
        @user.update_theme(theme)
        if email_ori != email_change and not email_change.blank?
          redirect_to setting_path, notice: "邮箱变更成功，请检查邮件进行激活！激活之后，请使用重置密码进行密码设置！"
        else
          redirect_to setting_path, notice: "更新成功"
        end
      else
        render "show"
      end
    end

    def update_profile
      if @user.update(user_params)
        @user.update_profile_fields(params[:user][:profiles])
        redirect_to profile_setting_path, notice: "更新成功"
      else
        render "profile"
      end
    end

    def update_reward
      reward_fields = params[:user][:rewards] || {}

      res = {}
      reward_fields.each do |key, value|
        photo = Photo.create(image: value)
        res[key] = photo.image.url
      end

      if @user.update_reward_fields(res)
        redirect_to reward_setting_path, notice: "更新成功"
      else
        render "reward"
      end
    end

    def update_password
      if @user.update_with_password(user_params)
        redirect_to new_session_path(:user), notice: "密码更新成功，现在你需要重新登录。"
      else
        render "password"
      end
    end
end
