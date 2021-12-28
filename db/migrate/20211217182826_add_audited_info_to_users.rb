class AddAuditedInfoToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :audited_at, :datetime
    add_column :users, :audit_user_id, :integer
    add_column :users, :audit_status, :string, default: 'pending'
    add_column :users, :audit_reason, :string
  end
end
