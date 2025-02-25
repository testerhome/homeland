# frozen_string_literal: true

module Api
  module V3
    class TopicsController < Api::V3::ApplicationController
      before_action :doorkeeper_authorize!, except: %i[index show replies]
      before_action :set_topic, except: %i[index create]

      # 获取话题列表，类似网站的 /topics 的结构，支持多种排序方式。
      #
      # GET /api/v3/topics
      #
      # @param type [String] 排序类型, default: `last_actived`, %w(last_actived recent no_reply popular excellent)
      # @param node_id [Integer] 节点编号，如果有给，就会只去节点下的话题
      # @param offset [Integer] default: 0
      # @param limit [Integer] default: 20, range: 1..150
      #
      # @return [Array<TopicSerializer>]
      def index
        optional! :type, default: "last_actived"
        optional! :node_id
        optional! :offset, default: 0
        optional! :limit, default: 20, values: 1..150

        params[:type] = params[:type].downcase

        if params[:node_id].blank?
          @topics = Topic
          if current_user
            @topics = @topics.without_nodes(current_user.block_node_ids)
            @topics = @topics.without_users(current_user.block_user_ids)
          else
            @topics = @topics.without_hide_nodes
          end
        else
          @node = Node.find(params[:node_id])
          @topics = @node.topics
        end

        @topics = @topics.without_draft.without_ban.fields_for_list.includes(:user).send(scope_method_by_type)
        if %w[no_reply popular].index(params[:type])
          @topics = @topics.last_actived
        elsif params[:type] == "excellent"
          @topics = @topics.recent
        end

        @topics = @topics.offset(params[:offset]).limit(params[:limit])
      end

      # 获取话题详情（不含回帖）
      #
      # GET /api/v3/topics/:id
      #
      # @param id [Integer] 话题编号
      # @return [TopicDetailSerializer] 此外 meta 里面包含当前用户对此话题的状态
      #
      # ```json
      # { followed: '是否已关注', liked: '是否已赞', favorited: '是否已收藏' }
      # ```
      def show
        if !@topic.team.blank?
          if @topic.team.private?
            if !current_user
              raise AccessDenied.new("请登录之后查看组织下面的文章！")
            elsif !@topic.team.member?(current_user) && !current_user.admin?
              raise AccessDenied.new("非组织成员无法查看组织下面的文章！")
            end
          end
        end
        @topic.hits.incr(1)

        @meta = { followed: false, liked: false, favorited: false }

        if current_user
          # 处理通知
          current_user.read_topic(@topic)
          @meta[:followed] = current_user.follow_topic?(@topic)
          @meta[:liked] = current_user.like_topic?(@topic)
          @meta[:favorited] = current_user.favorite_topic?(@topic)
        end
      end

      # 创建新话题
      #
      # POST /api/v3/topics
      #
      # @param title [String] 标题, [required]
      # @param node_id [Integer] 节点编号, [required]
      # @param body [Markdown] 格式的正文, [required]
      # @return [TopicDetailSerializer]
      def create
        requires! :title
        requires! :body
        requires! :node_id

        raise AccessDenied.new("当前登录的用户没有发帖权限，具体请参考官网的相关说明。") unless can?(:create, Topic)

        @topic = current_user.topics.new(title: params[:title], body: params[:body])
        @topic.node_id = params[:node_id]
        @topic.log_ip(request.remote_ip, request.headers["X-Client-Request-Port"])
        @topic.save!

        render "show"
      end

      # 更新话题
      #
      # POST /api/v3/topics/:id
      #
      # @param title [String] 标题, [required]
      # @param node_id [Integer] 节点编号, [required]
      # @param body [String] Markdown 格式的正文, [required]
      # @return [TopicDetailSerializer]
      def update
        requires! :title
        requires! :body
        requires! :node_id

        raise AccessDenied unless can?(:update, @topic)

        if @topic.lock_node == false || can?(:lock_node, @topic)
          # 锁定接点的时候，只有管理员可以修改节点
          @topic.node_id = params[:node_id]

          if @topic.node_id_changed? || can?(:lock_node, @topic)
            # 当管理员修改节点的时候，锁定节点
            @topic.lock_node = true
          end
        end
        @topic.title = params[:title]
        @topic.body = params[:body]
        @topic.log_ip(request.remote_ip, request.headers["X-Client-Request-Port"])
        
        @topic.save!

        render "show"
      end

      # 删除话题
      #
      # DELETE /api/v3/topics/:id
      def destroy
        raise AccessDenied unless can?(:destroy, @topic)
        @topic.destroy_by(current_user)
        render json: { ok: 1 }
      end

      # 获取话题的回帖列表
      #
      # GET /api/v3/topics/:id/replies
      #
      # @param offset [Integer] default: 0
      # @param limit [Integer] default: 20, range: 1..150
      # @return [Array<ReplySerializer]>
      def replies
        if request.post?
          create_replies
          return
        end

        params[:limit] ||= 20

        @replies = Reply.unscoped.where(topic_id: @topic.id).order(:id).includes(:user)
        @replies = @replies.offset(params[:offset].to_i).limit(params[:limit].to_i)

        @replies = @replies.map do |r|
          if not r.exposed_to_author_only? || (current_user && (r.topic && r.topic.user == current_user || r.user == current_user))
            r
          else
            r.body = I18n.t("topics.exposed_to_author_only")
            r
          end
        end

        @user_liked_reply_ids = current_user&.like_reply_ids_by_replies(@replies) || []
        @meta = { user_liked_reply_ids: @user_liked_reply_ids }
      end

      # 创建对话题的回帖
      #
      # POST /api/v3/topics/:id/replies
      #
      # @param body [String] 回帖内容，[required]
      # @return [ReplySerializer] 创建的回帖信息
      def create_replies
        doorkeeper_authorize!

        requires! :body

        raise AccessDenied.new("当前用户没有回帖权限，具体请参考官网的说明。") unless can?(:create, Reply)

        @reply = @topic.replies.build(body: params[:body])
        @reply.user_id = current_user.id
        @reply.save!
        render "api/v3/replies/show"
      end

      # 关注话题
      #
      # POST /api/v3/topics/:id/follow
      def follow
        current_user.follow_topic(@topic)
        render json: { ok: 1 }
      end

      # 取消关注话题
      #
      # POST /api/v3/topics/:id/unfollow
      def unfollow
        current_user.unfollow_topic(@topic)
        render json: { ok: 1 }
      end

      # 收藏话题
      #
      # POST /api/v3/topics/:id/favorite
      def favorite
        current_user.favorite_topic(@topic.id)
        render json: { ok: 1 }
      end

      # 取消收藏话题
      #
      # POST /api/v3/topics/:id/unfavorite
      def unfavorite
        current_user.unfavorite_topic(@topic.id)
        render json: { ok: 1 }
      end

      # 屏蔽话题 (Admin only)
      # [废弃] 请用 POST /api/v3/topics/:id/action
      #
      # POST /api/v3/topics/:id/ban
      def ban
        raise AccessDenied.new("当前用户没有屏蔽别人话题的权限，具体请参考官网的说明。") unless can?(:ban, @topic)
        @topic.ban!
        render json: { ok: 1 }
      end

      # 更多功能
      # 注意类型有不同的权限，详见 GET /api/v3/topics/:id 返回的 abilities
      #
      # POST /api/v3/topics/:id/action?type=:type
      # @param type [String] 动作类型, ban - 屏蔽话题, normal - 取消屏蔽, excellent - 加精华, unexcellent - 取消精华, close - 关闭回复, open - 开启回复
      def action
        raise AccessDenied unless can?(params[:type].to_sym, @topic)

        case params[:type]
        when "excellent"
          @topic.excellent!
        when "unexcellent"
          @topic.unexcellent!
        when "normal"
          @topic.normal!
        when "ban"
          @topic.ban!
        when "close"
          @topic.close!
        when "open"
          @topic.open!
        end
        render json: { ok: 1 }
      end

      private

      def set_topic
        @topic = Topic.find(params[:id])
      end

      def scope_method_by_type
        case params[:type]
        when "last_actived" then :last_actived
        when "recent" then :recent
        when "no_reply" then :no_reply
        when "popular" then :popular
        when "excellent" then :excellent
        else
          :last_actived
        end
      end
    end
  end
end
