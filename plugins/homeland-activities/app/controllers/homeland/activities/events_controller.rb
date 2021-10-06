require_dependency "homeland/activities/application_controller"
require 'groupdate'
module Homeland::Activities
  class EventsController < ::ApplicationController
    before_action :set_event, only: [:show, :edit, :update, :destroy, :replies]

    # GET /events
    def index
      if current_user
        @edit_event = Event.where(user_id: current_user.id, status: %w[init waitting_audit  failure]).first
      end

      @city_filter = params[:city].to_s.strip
      @category_filter = params[:category]


      @events = Event.allowed
      if @city_filter.present? && @city_filter != "所有城市"
        @events = @events.where(event_city: @city_filter)
      end

      if @category_filter.present? && @category_filter != "不限类型"
        @events = @events.where(category: @category_filter)
      end

      @top_events = Event.allowed.pinned
      @events_count_in_curerent_month = @events.allowed.where("start_at >= ? and start_at <= ?", Time.now.beginning_of_month - 7.days, Time.now.end_of_month + 7.days).group_by_day(:start_at).count
      # 注意顺序， 先出日历， 再进行细分
      if !params[:filter_date].blank?

        @filter_date = Time.parse(params[:filter_date]) rescue nil
        @events = @events.where("start_at >= ? and start_at <= ?", @filter_date.beginning_of_day, @filter_date.end_of_day) unless @filter_date.nil?
      end
      @incoming_events = @events.incoming_events

      @old_events = @events.old_events.order("start_at desc").page(params[:page]).per(12)
    end
    # GET /events/1
    def show
      @commentable = @event.comments.new
    end

    def replies
      @reply = Reply.new(params.require(:reply).permit(:body, :reply_to_id))
      @reply.target_id = @event.id
      @reply.user_id = current_user.id
      if @reply.save
        @msg = t("topics.reply_success")
      else
        @msg = @reply.errors.full_messages.join("<br />")
      end
    end

    # GET /events/new
    def new
      if current_user.nil?
        return redirect_to '/account/sign_in'
      end
      @event = Event.new
    end

    # GET /events/1/edit
    def edit
      if status == 'success' && !current_user.admin?
        redirect_to @event
      end
    end

    # POST /events
    def create
      @event = Event.new(event_params)
      @event.user = current_user

      if @event.save
        redirect_to [:edit, @event, step: 1]
      else
        render :new
      end
    end

    # PATCH/PUT /events/1
    def update
      @event.status = "waitting_audit" if params[:step].to_i == 1 && !current_user.admin?

      if @event.update(event_params)
        if params[:step].to_i == 0
          redirect_to [:edit, @event, step: 1]
        elsif params[:step].to_i == 1
          redirect_to @event
        end
      else
        render :edit, step: params[:step]
      end
    end

    # DELETE /events/1
    def destroy
      @event.destroy
      redirect_to events_url, notice: "Event was successfully destroyed."
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event

        if action_name == "show"
          event = Event.find(params[:id])
          return @event = event if event.status == "success"
        end
        return @event = Event.find(params[:id]) if current_user&.admin?

        @event = Event.where(user_id: current_user&.id).find(params[:id])

      end

      # Only allow a list of trusted parameters through.
      def event_params
        params.require(:event).permit(:city,


          :photo_url,
          :category,
          :title,
          :start_at,
          :end_at,
          :registration_open_at,
          :registration_end_at,
          :description,
          :operator_info,
          :realname,
          :email,
          :phone,
          :wechat_or_qq,
          :register_category_info,
          :host_name,
          :host_url,
          :markup,
          :markup_url,
          :event_city,
          :event_city_info,
          cooperators: [:name, :url]
        )
      end
  end
end
