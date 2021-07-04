# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  def create
    email = params[resource_name][:email]
    if email.include?("@example.com")
      set_flash_message :warning, :"mail_from_github"
      return
    end

    resource_instance = resource_class.find_by_email email
    if resource_instance && ! resource_instance.active_for_authentication?
      resource_instance.send_confirmation_instructions
    elsif not resource_instance
      set_flash_message :warning, :"mail_not_existed"
    else
      set_flash_message :warning, :"mail_has_actived", email: resource_instance.email
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      redirect_to(after_confirmation_path_for(resource_name, resource), notice:  "您的账号已经激活，请继续新人流程！")
    else
      render :new
    end
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource)
    super(resource_name, resource)
  end
end
