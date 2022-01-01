class HasEarnCreateCredit < ActiveRecord::Migration[6.1]
  def change
    add_column :topics, :has_earn_create_credit, :boolean, default: false
    add_column :replies, :has_earn_create_credit, :boolean, default: false
    add_column :users, :has_earn_create_credit, :boolean, default: false
  end
end
