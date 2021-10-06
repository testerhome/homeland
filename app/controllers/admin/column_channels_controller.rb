module Admin
  class ColumnChannelsController < Admin::ApplicationController
    def show
      @column_channel_right_ads = Setting.column_channel_right_ads.map do |item|
        key, value = item.split("$$$")
        {img_url: key, link: value}
      end

      @column_channel_top_ads = Setting.column_channel_top_ads.map do |item|
        key, value = item.split("$$$")
        {img_url: key, link: value}
      end

    end

    def update
      if params[:top_ad_update]
        Setting.column_channel_top_ads = build_ad_info_from_params
      end

      if params[:right_ad_update]
        Setting.column_channel_right_ads = build_ad_info_from_params
      end

      if params[:raw_html_settings_update]
        Setting.column_channel_top_raw_html = params[:top_raw_html]
        Setting.column_channel_right_raw_html = params[:right_raw_html]
      end

      if params[:update_column_channel_simple_column_ids]
        Setting.column_channel_simple_column_ids = params[:column_channel_simple_column_ids].to_s.split(',')
      end

      if params[:update_column_channel_public_enterprise_column_ids]
        Setting.column_channel_public_enterprise_column_ids = params[:column_channel_public_enterprise_column_ids].to_s.split(',')
      end

      redirect_to [:admin, :column_channels], notice: "已经存储"
    end

    private

    def build_ad_info_from_params
      arr = []
      (params[:image_url]|| []).each_with_index do |image_url, index|
        arr << "#{image_url}$$$#{params[:link][index]}"
      end
      arr
    end
  end
end