class CreateThirdLoginApps < ActiveRecord::Migration[6.1]
  def change
    create_table :third_login_apps do |t|
      t.string :name
      t.string :description
      t.string :api_token
      t.string :login_url

      t.timestamps
    end
  end
end
