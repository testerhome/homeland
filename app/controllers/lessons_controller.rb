class LessonsController < ApplicationController
  def index
    @list = GeekBangLessonHelper.fetch_list
    Rails.logger.info @list
  end

  def show
    @details = GeekBangLessonHelper.fetch_lesson_details(params[:id])
    article_id = GeekBangLessonHelper.fetch_article_id_from_course_id(params[:id])
    @article_info = GeekBangLessonHelper.fetch_article_info(article_id, true)
    Rails.logger.info "article_info: #{@article_info}"
  end
end
