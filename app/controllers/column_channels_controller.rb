# 注意， 此处的专栏和 基于用户开出来的专栏不一样
class ColumnChannelsController < ApplicationController
  include Topics::ListActions
  def index
    @topics = topics_scope.where("state > 100").page(params[:page])
  end
end
