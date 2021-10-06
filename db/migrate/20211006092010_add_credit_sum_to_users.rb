class AddCreditSumToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :credit_sum, :integer
  end
end
