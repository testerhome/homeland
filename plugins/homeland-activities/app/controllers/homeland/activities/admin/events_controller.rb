module Homeland::Activities
  module Admin
    class EventsController < ::Admin::ApplicationController
      before_action :set_event, only: %i[show edit update destroy undestroy suggest unsuggest publish failure]
      layout 'layouts/admin'

      def index
        @events = Event.includes(:user).order("id desc").page(params[:page])


        if params[:q].present?
          qstr = "%#{params[:q].downcase}%"
          @events = @events.where("title LIKE ?", qstr)
        end
        if params[:login].present?
          u = User.find_by_login(params[:login])
          @events = @events.where("user_id = ?", u.try(:id))
        end

        @events = @events.order(id: :desc)
        @events = @events.includes(:user).page(params[:page])
      end

      def edit
      end

      def suggest
        @event.update_attribute(:suggested_at, Time.now)
        redirect_to(admin_events_path, notice: "话题置顶成功")
      end

      def unsuggest
        @event.update_attribute(:suggested_at, nil)
        redirect_to(admin_events_path, notice: "话题已取消置顶")
      end

      def publish
        @event.update_attribute(:status, "success")

        respond_to do |format|
          format.html {redirect_to admin_events_path}
        end

      end

      def failure
        @event.update_attribute(:status, 'failure')
        redirect_to admin_events_path
      end

      private

      def set_event
        @event = Event.find(params[:id])
      end
    end


  end
end