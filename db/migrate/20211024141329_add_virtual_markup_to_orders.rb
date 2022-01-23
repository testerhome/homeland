class AddVirtualMarkupToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_variant_orders, :virtual_markup, :string
  end
end
