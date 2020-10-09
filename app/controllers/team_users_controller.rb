# frozen_string_literal: true

class TeamUsersController < ApplicationController
  require_module_enabled! :team

  before_action :set_team
  before_action :set_team_user, only: [:edit, :update, :destroy, :show_approve, :edit_user, :update_user]
  before_action :authorize_team_owner!, except: [:index, :accept, :accept_join, :reject, :reject_join, :show, :show_approve, :join, :edit_user, :update_user]
  load_and_authorize_resource only: [:accept, :reject, :accept_join, :reject_join, :show, :show_approve, :update_user]

  def index
    @team_users = @team.team_users
    if cannot? :update, @team
      @team_users = @team_users.accepted
    end
    @team_users = @team_users.order("id asc").includes(:user).page(params[:page])
  end

  def new
    @team_user = @team.team_users.new
    @team_user.role = :member
  end

  def create
    @team_user = TeamUser.new(team_user_params)
    @team_user.team_id = @team.id
    @team_user.actor_id = current_user.id
    @team_user.status = :pendding
    if @team_user.save(context: :invite)
      redirect_to(user_team_users_path(@team), notice: "邀请成功。")
    else
      render action: "new"
    end
  end

  def edit
  end

  def edit_user
  end

  def update_user
    if @team_user.update(params.require(:team_user).permit(:is_receive_notifications))
      redirect_to(edit_user_user_team_user_path(@team), notice: "保存成功")
    else
      render action: "edit_user"
    end
  end

  def update
    if @team_user.update(params.require(:team_user).permit(:role))
      redirect_to(user_team_users_path(@team), notice: "保存成功")
    else
      render action: "edit"
    end
  end

  def destroy
    @team_user.destroy
    redirect_to(user_team_users_path(@team), notice: "移除成功")
  end

  def show
    if @team_user.accepted?
      redirect_to user_team_users_path(@team)
    end
  end

  def show_approve
    if @team_user.accepted?
      redirect_to user_team_users_path(@team)
    end
  end

  def join
    if @team.ready_to_be_member? current_user
      redirect_to(user_team_users_path(@team), notice: '请耐心等待，勿重复申请！')
    else
      @team_user = TeamUser.new
      @team_user.role = :member
      @team_user.team_id = @team.id
      @team_user.login = current_user.login
      @team_user.actor_ids = @team.team_admin_ids
      @team_user.status = :pendding_owner_approved
      @team_user.comment = params[:comment]
      if @team_user.save(context: :invite)
        redirect_to(user_team_users_path(@team), notice: '申请成功，等待审批。')
      else
        redirect_to(user_team_users_path(@team), notice: '申请失败，请重新申请。')
      end
    end
  end

  def accept
    @team_user.accepted!
    redirect_to(user_team_users_path(@team), notice: "接受成功，已加入社团")
  end

  def accept_join
    @team_user.accepted!
    redirect_to(user_team_users_path(@team), notice: '批准申请，已加入社团')
  end

  def reject
    @team_user.destroy
    redirect_to(user_team_users_path(@team), notice: "已拒绝成功")
  end

  def reject_join
    return if not @team_user.team.owner? current_user
    @team_user.actor_ids = [current_user.id]
    reject_join_reason = params[:reject_join_reason]
    @team_user.reject_user_join(reject_join_reason)
    redirect_to(user_team_users_path(@team), notice: '已拒绝申请成功')
  end

  private

    def authorize_team_owner!
      authorize! :update, @team
    end

    def set_team_user
      @team_user = @team.team_users.find(params[:id])
    end

    def set_team
      @team = Team.find_by_login!(params[:user_id])
    end

    def team_user_params
      params.require(:team_user).permit(:login, :user_id, :role)
    end
end
