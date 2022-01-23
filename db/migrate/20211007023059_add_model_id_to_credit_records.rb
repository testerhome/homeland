class AddModelIdToCreditRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_records, :model_id, :integer
    add_column :credit_records, :model_type, :string

    add_index :credit_records, :model_id
    add_index :credit_records, :model_type
  end
end
