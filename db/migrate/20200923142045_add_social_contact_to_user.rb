class AddSocialContactToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :score, :integer, default: 1000, null: false
    add_column :users, :wechat, :string
    add_column :users, :wechat_public, :boolean
    add_column :users, :qq, :string
    add_column :users, :qq_public, :boolean
    add_column :users, :weibo, :string
    add_column :users, :weibo_public, :boolean
    add_column :users, :co, :string
    add_column :users, :qrcode, :string
  end
end
