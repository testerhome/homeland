class CreateCreditRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :credit_records do |t|
      t.references :user, null: false, foreign_key: true
      t.string :category
      t.string :reason
      t.integer :num
      t.string :operator
      t.jsonb :meta
      t.string :markup

      t.timestamps
    end
  end
end
