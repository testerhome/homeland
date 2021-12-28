class AddAuditFunctionsToReplies < ActiveRecord::Migration[6.1]
  def change
    add_column :replies, :audited_at, :datetime
    add_column :replies, :audit_user_id, :integer
    add_column :replies, :audit_status, :string, default: 'pending'
    add_column :replies, :audit_reason, :string
  end
end
