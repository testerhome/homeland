class AddBalanceToCreditRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_records, :balance, :integer
  end
end
