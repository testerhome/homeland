module Admin
  class ColumnChannelsController < Admin::ApplicationController
    def show

    end

    def update
      if params[:top_ad_update]
        Setting.column_channel_top_image_url = params[:column_channel_top_image_url]
        Setting.column_channel_top_url = params[:column_channel_top_url]
      end

      if params[:right_ad_update]
        Setting.column_channel_right_image_url = params[:column_channel_right_image_url]
        Setting.column_channel_right_url = params[:column_channel_right_url]
      end

      if params[:update_column_channel_simple_column_ids]
        Setting.column_channel_simple_column_ids = params[:column_channel_simple_column_ids].to_s.split(',')
      end

      if params[:update_column_channel_public_enterprise_column_ids]
        Setting.column_channel_public_enterprise_column_ids = params[:column_channel_public_enterprise_column_ids].to_s.split(',')
      end

      redirect_to [:admin, :column_channels], notice: "已经存储"
    end
  end
end