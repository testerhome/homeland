# 注意， 此处的专栏和 基于用户开出来的专栏不一样
class ColumnChannelsController < TopicsController
  def index
    @simple_columns = Setting.column_channel_simple_column_ids.map {|id| Column.find_by_id(id) }.reject(&:nil?)
    @public_enterprise_columns = Setting.column_channel_public_enterprise_column_ids.map {|id| Column.find_by_id(id) }.reject(&:nil?)

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

  def fetch_public_or_enterprise_topics
    if ["120-129", "130-139"].include? params[:user_states_category]
      keys = params[:user_states_category].split("-").map(&:to_i)
      topics_scope.joins(:user).where("users.state between ? and ?", *keys).order("date(topics.created_at) desc, users.state desc, topics.created_at desc")
    else
      topics_scope.public_and_enterprise_topics.order(Arel.sql("date(topics.created_at) desc, array_position(array[131,122,130,120,121], users.state)"))
    end
  end

  def fetch_section_topics
    topics_scope.includes(:node).where("node.section_id" =>  params[:section_id]).order(Arel.sql("date(topics.created_at) desc"))
  end
end
