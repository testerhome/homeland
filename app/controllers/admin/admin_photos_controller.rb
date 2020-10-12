# frozen_string_literal: true

module Admin
  class AdminPhotosController < Admin::ApplicationController
    before_action :set_photo, only: %i[show]

    def show
    end

    def new
      @photo = AdminPhoto.new
    end

    def create
      @photo = AdminPhoto.new(params[:admin_photo].permit!)
      @photo.user_id = current_user.id
      if @photo.save
        redirect_to(admin_admin_photo_path(@photo), notice: 'Photo was successfully created.')
      else
        render action: 'new'
      end
    end


    private

      def set_photo
        @photo = AdminPhoto.find(params[:id])
      end
  end
end
