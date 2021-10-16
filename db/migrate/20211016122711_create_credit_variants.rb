class CreateCreditVariants < ActiveRecord::Migration[6.1]
  def change
    create_table :credit_variants do |t|
      t.string :sku
      t.string :image_url
      t.string :title
      t.string :description
      t.references :credit_product
      t.decimal :credit_price, precision: 8, scale: 2, default: 0.0, null: false

      t.timestamps
    end
  end
end
