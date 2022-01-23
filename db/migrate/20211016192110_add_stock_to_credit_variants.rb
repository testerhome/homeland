class AddStockToCreditVariants < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_variants, :stock, :integer
  end
end
