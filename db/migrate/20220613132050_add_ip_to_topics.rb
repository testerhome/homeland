class AddIpToTopics < ActiveRecord::Migration[6.1]
  def change
    add_column :topics, :ip, :string
    add_column :topics, :ip_location, :string
  end
end
