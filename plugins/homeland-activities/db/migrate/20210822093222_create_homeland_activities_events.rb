class CreateHomelandActivitiesEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :homeland_activities_events do |t|
      t.string :city
      t.string :category
      t.string :title
      t.datetime :start_at
      t.datetime :end_at
      t.datetime :registration_open_at
      t.datetime :registration_end_at
      t.datetime :suggested_at
      t.string :register_category
      t.string :register_category_info
      t.string :event_city
      t.string :event_city_info
      t.string :description
      t.json :operator_info
      t.string :realname
      t.string :email
      t.string :phone
      t.string :wechat_or_qq
      t.string :status, default: 'init'
      t.integer :user_id
      t.integer :comments_count, default: 0, null: false

      t.timestamps
    end
  end
end
