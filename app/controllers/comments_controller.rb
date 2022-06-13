# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.log_ip(request.remote_ip, request.headers["X-Client-Request-Port"])
    @success = @comment.save
  end

  def comment_params
    params.require(:comment).permit(:commentable_type, :commentable_id, :body)
  end
end
