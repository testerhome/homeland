class CreateCreditProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :credit_products do |t|
      t.string :title
      t.string :main_image_url
      t.string :category
      t.string :description
      t.string :state

      t.timestamps
    end
  end
end
