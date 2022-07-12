class AddThirdUniqueIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :third_unique_id, :string
    add_index :users, :third_unique_id, unique: true
  end
end
