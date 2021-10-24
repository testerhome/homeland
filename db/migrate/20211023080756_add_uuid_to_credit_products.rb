class AddUuidToCreditProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_products, :uuid, :string
  end
end
