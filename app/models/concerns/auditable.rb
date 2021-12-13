module Auditable 
  extend ActiveSupport::Concern

  # audited_at, audit_by, audit_reason

  included do
    enum audit_status: {
      pending: 'pending',
      approved: 'approved',
      rejected: 'rejected',
      punished: 'punished'
    }
  end

  def audit(audit_user_id, audit_status, audit_reason)
    self.update(audit_status: audit_status, 
                audited_at: Time.now, 
                audit_by: audit_user_id)
  end


end