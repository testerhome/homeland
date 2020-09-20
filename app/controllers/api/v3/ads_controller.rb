module Api
  module V3
  class AdsController < Api::V3::ApplicationController
    def not_found
      raise ActiveRecord::RecordNotFound
    end

    def index
      optional! :limit, default: 3, values: 1..5

      limit = params[:limit].to_i
      limit = 5 if limit > 5
      @ads = Ad.limit(limit)
    end
  end
  end
end

