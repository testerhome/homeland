# frozen_string_literal: true

module Admin
  class CreditSettingsController < Admin::ApplicationController
    def index
      @sections = Section.all
      @tech_node_ids = Setting.tech_node_ids

      @credit_products_top_ads = Setting.credit_products_top_ads.map do |item|
        key, value = item.split("$$$")
        {img_url: key, link: value}
      end
    end

    def sync_tech_node_ids
      Setting.tech_node_ids =  params[:tech_nodes].map(&:to_i)
      redirect_to admin_credit_settings_path, notice: "更新完毕"
    end

    def create
      Setting.tech_topic_created_credit = params[:tech_topic_created_credit]
      Setting.question_created_credit = params[:question_created_credit]
      Setting.excellent_topic_credit = params[:excellent_topic_credit]
      Setting.topic_user_reply_reward_credit = params[:topic_user_reply_reward_credit]
      Setting.topic_reply_credit = params[:topic_reply_credit]
      Setting.topic_reply_credit_limit = params[:topic_reply_credit_limit]
      Setting.topic_like_credit = params[:topic_like_credit]
      Setting.reply_like_credit = params[:reply_like_credit]
      Setting.question_best_answer_credit = params[:question_best_answer_credit]
      Setting.invite_code_registered_credit = params[:invite_code_registered_credit]
      Setting.login_credit = params[:login_credit]

      Setting.credit_products_top_ads = build_ad_info_from_params
      redirect_to admin_credit_settings_path, notice: "更新完毕"
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