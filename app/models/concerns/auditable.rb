module Auditable 
  extend ActiveSupport::Concern

  # audited_at, audit_by, audit_reason

  included do
    enum audit_status: {
      pending: 'pending',
      approved: 'approved',
      rejected: 'rejected',
      punished: 'punished'
    }, _prefix: 'audit'

    before_create :set_default_audit_status
    before_update :check_audit_status_when_change
  end

  def set_default_audit_status
    if modelClass = [User, Topic, Reply, Comment].find{|klass| self.is_a? klass}
      if self.respond_to?(:user) && (Setting.audit_user_whitelist || []).include?(self.user&.login)
        self.audit_reason = "whitelist"
        return self.audit_status = 'approved' 
      end

      self.audit_status = 'approved' if Setting.send("enable_audit_#{modelClass.name.underscore.pluralize}_create") == false
    end
  end

  def check_audit_status_when_change
    if modelClass = [User, Topic, Reply, Comment].find{|klass| self.is_a? klass}

      # 当启用了修改检查
      if Setting.send("enable_audit_#{modelClass.name.underscore}_update") 
        attributes = Setting.send("audit_#{modelClass.name.underscore}_update_attributes")
        self.audit_status = 'pending' if attributes.find {|attribute| self.send("#{attribute}_changed?") }
      end
    end
  end

  def audit(audit_user_id, audit_status, audit_reason)
    self.update(audit_status: audit_status, 
                audited_at: Time.now, 
                audit_by: audit_user_id)
  end


end