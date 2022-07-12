# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, except: %i[index city third_app_login ticket_to_user]
  before_action :check_exist!, except: %i[index city block unblock third_app_login ticket_to_user
                                          follow unfollow]

  skip_before_action :verify_authenticity_token, only: :ticket_to_user

  etag { @user }
  etag { @user&.teams if @user&.user_type == :user }

  include Users::TeamActions
  include Users::UserActions

  def index
    @total_user_count = User.count
    @active_users = User.without_team.fields_for_list.hot.limit(100)
  end

  def third_app_login
    authenticate_user!

    name = params[:name]
    return render_404 if name.blank?

    third_app = ThirdLoginApp.find_by(name: name)
    return render_404 if third_app.nil?

    redirect_to "#{third_app.login_url}?to=#{name}&source=testerhome&ticket=#{current_user.fetch_third_ticket}"
  end

  def ticket_to_user
    ticket = params[:ticket]
    return render_404 if ticket.blank?

    user = User.find_by_third_ticket(ticket, params[:source], params[:api_token])
    return render_404 if user.nil?

    render json: {
      loginName: user.login,
      userName: user.name,
      mobile: user.phone_number,
      email: user.email,
      sourceId: user.third_unique_id,
    }
  end

  def city
    location = Location.location_find_by_name(params[:id])
    return render_404 if location.nil?
    @users = User.where(location_id: location.id).without_team.fields_for_list
    @users = @users.order(replies_count: :desc).page(params[:page]).per(60)

    render_404 if @users.count == 0
  end

  def show
    @user_type == :team ? team_show : user_show
  end

  protected

  def set_user
    @user = User.find_by_login!(params[:id])

    # 转向正确的拼写
    if @user.login != params[:id]
      redirect_to user_path(@user.login), status: 301
      return
    end

    @user_type = @user.user_type
  end

  def check_exist!
    render_404 if @user.deleted?
  end

  # Override render method to render difference view path
  def render(*args)
    options = args.extract_options!
    if @user_type
      options[:template] ||= "/#{@user_type.to_s.tableize}/#{params[:action]}"
    end
    super(*(args << options))
  end
end
