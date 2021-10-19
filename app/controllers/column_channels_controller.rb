# 注意， 此处的专栏和 基于用户开出来的专栏不一样
class ColumnChannelsController < TopicsController
  def index
    load_ads
    @simple_columns = Setting.column_channel_simple_column_ids.map {|id| Column.find_by_id(id) }.reject(&:nil?)
    @public_enterprise_columns = Setting.column_channel_public_enterprise_column_ids.map {|id| Column.find_by_id(id) }.reject(&:nil?)

    @sections = Section.all.reject {|s| ['私密圈子', '测试服务'].include? s.name }

    if params[:section_id].blank?
      @topics = fetch_public_or_enterprise_topics
    else
      @topics = fetch_section_topics
    end
    @topics = @topics.page(params[:page])
  end

  def section
  end

  private

  def load_ads
    @column_channel_right_ads = Setting.column_channel_right_ads.map do |item|
      key, value = item.split("$$$")
      {img_url: key, link: value}
    end

    @column_channel_top_ads = Setting.column_channel_top_ads.map do |item|
      key, value = item.split("$$$")
      {img_url: key, link: value}
    end

  end

  def fetch_public_or_enterprise_topics
    if ["120-129", "130-139"].include? params[:user_states_category]
      keys = params[:user_states_category].split("-").map(&:to_i)
      add_or_condition = params[:user_states_category] == '120-129' ? "or topics.node_id = #{Setting.article_node}" : ""
      topics_scope.joins(:user).where("users.state between ? and ? #{add_or_condition}", *keys).order("date(topics.created_at) desc, users.state desc, topics.created_at desc")
    else
      # topics_scope.public_and_enterprise_topics.order(Arel.sql("date(topics.created_at) desc, array_position(array[131,122,130,120,121], users.state)"))
      keys = [120, 139]
      add_or_condition = true ? "or topics.node_id = #{Setting.article_node}" : ""
      topics_scope.joins(:user).where("users.state between ? and ? #{add_or_condition}", *keys).order("date(topics.created_at) desc, users.state desc, topics.created_at desc")
    end
  end

  def fetch_section_topics
    topics_scope.includes(:node).
    where("node.section_id" =>  params[:section_id]).
    # 注意这里需要与node 的 sort 保持一致， 而 node 的 sort 实际上是 过滤，需要注意.....
    # 55是违规处理区， 61 是 NoPoint
    where.not(node_id: [Setting.article_node, 55, 61]).

    order(Arel.sql("date(topics.created_at) desc"))
  end
end
