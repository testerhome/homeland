# frozen_string_literal: true

module Admin
  class NodesController < Admin::ApplicationController
    before_action :set_node, only: %i[show edit update destroy]

    def index
      @nodes = Node.sorted.includes(:section)
    end

    def show
    end

    def new
      @node = Node.new
    end

    def edit
      authorize! :update, @node
    end

    def create
      @node = Node.new(params[:node].permit!)

      if @node.save
        redirect_to(admin_nodes_path, notice: "Node was successfully created.")
      else
        render action: "new"
      end
    end

    def update
      authorize! :update, @node
      if @node.update(params[:node].permit!)
        redirect_to(admin_nodes_path, notice: "Node was successfully updated.")
      else
        render action: "edit"
      end
    end

    def destroy
      authorize! :destroy, @node
      @node.destroy
      redirect_to(admin_nodes_url)
    end

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to admin_nodes_path, alert: "无此操作权限，可能因为该节点已经分配了版主"
    end

    private

      def set_node
        @node = Node.find(params[:id])
      end
  end
end
