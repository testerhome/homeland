class CreateInviteCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :invite_codes do |t|
      t.string :code, null: false
      t.string :creater_id
      t.string :consumer_id
      t.bigint :expired_in
      t.timestamps
    end
  end
end
