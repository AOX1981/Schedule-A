class AuditLogSerializer
  include Alba::Resource

  attributes :id, :auditable_type, :auditable_id, :action,
             :changed_fields, :ip_address, :created_at
end
