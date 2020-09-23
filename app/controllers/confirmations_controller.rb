# frozen_string_literal: true

class ConfirmationsController < Devise::ConfirmationsController
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

    super
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

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
