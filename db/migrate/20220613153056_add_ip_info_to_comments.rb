class AddIpInfoToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :ip, :string
    add_column :comments, :ip_location, :string
    add_column :comments, :remote_port, :string
  end
end
