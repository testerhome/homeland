class AddPositionToCreditVariants < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_variants, :position, :integer
    add_column :credit_products, :position, :integer
  end
end
