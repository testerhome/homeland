class AddSuggestNodeToTopics < ActiveRecord::Migration[6.0]
  def change
    add_column :topics, :suggested_node, :integer, default: nil
  end
end
