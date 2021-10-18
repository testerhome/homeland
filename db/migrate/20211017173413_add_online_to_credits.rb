class AddOnlineToCredits < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_products, :online, :boolean, default: true
    add_column :credit_variants, :online, :boolean, default: true
  end
end
