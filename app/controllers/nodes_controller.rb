# frozen_string_literal: true

class NodesController < ApplicationController
  before_action :authenticate_user!, only: %i[block unblock]

  def index
    @nodes = Node.all
    if params[:section_id].present?
      @nodes = @nodes.where(section_id: params[:section_id])
    end
    render json: @nodes, only: [:name], methods: [:id]
  end

  def block
    current_user.block_node(params[:id])
    render json: { code: 0 }
  end

  def unblock
    current_user.unblock_node(params[:id])
    render json: { code: 0 }
  end
end
