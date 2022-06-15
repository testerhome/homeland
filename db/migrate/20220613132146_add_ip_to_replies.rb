class AddIpToReplies < ActiveRecord::Migration[6.1]
  def change
    add_column :replies, :ip, :string
    add_column :replies, :ip_location, :string
  end
end
