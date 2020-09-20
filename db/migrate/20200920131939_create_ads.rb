class CreateAds < ActiveRecord::Migration[6.0]
  def change
    create_table :ads do |t|
      t.string "topic_id", null: false
      t.string "topic_title", null: false
      t.string "topic_author", null: false
      t.string "cover", null: false
      t.timestamps
    end

    add_index :ads, :topic_id
  end
end
