class AddAuditFunctionsToTopics < ActiveRecord::Migration[6.1]
  def change
    add_column :topics, :audited_at, :datetime
    add_column :topics, :audit_user_id, :integer
    add_column :topics, :audit_status, :string, default: 'pending'
    add_column :topics, :audit_reason, :string
  end
end
