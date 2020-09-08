class AddCertifiedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :certified_at, :datetime
  end
end
