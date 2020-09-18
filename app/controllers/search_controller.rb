# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :authenticate_user!, only: [:users]

  def index
    params[:q] ||= ""

    @search = Homeland::Search.new(params[:q])

    if params[:excellent].present? && params[:excellent] == "1"
      @result = @search.query_results.joins("JOIN topics ON (searchable_type = 'Topic' AND topics.grade = #{Topic.grades[:excellent]} AND topics.id = searchable_id)").page(params[:page])
    else
      @result = @search.query_results.includes(:searchable).page(params[:page])
    end
  end

  def users
    @result = User.search(params[:q], user: current_user, limit: params[:limit] || 10)
    render json: @result.collect { |u| { login: u.login, name: u.name, avatar_url: u.large_avatar_url } }
  end
end
