class AddUuidToCreditVariantOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_variant_orders, :uuid, :string
  end
end
