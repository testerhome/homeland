# frozen_string_literal: true

class CertifyController < ApplicationController
  before_action :set_certify_question_choice_list, only: [:index]

  def index
    if current_user && current_user.certified?
      redirect_to main_app.root_path, notice: t("common.no_need_to_cerify")
    end
  end

  def answer
    flag = true
    certify_question_answer_list.each do |q, answer|
      if params[q].blank?
        flag = false
        break
      end
      answer_from_user = params[q].sort
      if answer.sort != answer_from_user
        flag = false
        break
      end
    end
    if flag
      current_user.certified
      redirect_to main_app.root_path, notice: "认证成功！"
    else
      redirect_to main_app.certify_path, alert: "答案错误！请关注公众号获取最新信息！"
    end
  end


  protected

    def certify_question_answer_list
      map = {}
      Setting.certify_questions_list.map do |str|
        map[str.split(":")[0]] = str.split(":")[2].split(",").map { |value| value.strip }
      end

      map
    end

    def set_certify_question_choice_list
      @certify_question_choice_list = {}
      Setting.certify_questions_list.map do |str|
        @certify_question_choice_list[str.split(":")[0]] = str.split(":")[1].split(",").map { |value| value.strip }
      end
      @certify_question_choice_list
    end
end
