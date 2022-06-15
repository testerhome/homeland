class AddRemotePortToReplies < ActiveRecord::Migration[6.1]
  def change
    add_column :replies, :remote_port, :string
    add_column :topics, :remote_port, :string
  end
end
