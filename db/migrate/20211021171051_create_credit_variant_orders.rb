class CreateCreditVariantOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :credit_variant_orders do |t|
      t.references :credit_variant, null: false, foreign_key: true
      t.integer :num
      t.string :status
      t.references :user, null: false, foreign_key: true
      t.string :deliver_address
      t.string :deliver_category
      t.string :deliver_markup
      t.string :deliver_no
      t.string :deliver_receiver_name
      t.string :deliver_receiver_phone
      t.decimal :current_credit_price
      t.integer :authen_user_id

      t.timestamps
    end
  end
end
