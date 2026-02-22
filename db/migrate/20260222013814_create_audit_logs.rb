class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :auditable_type, null: false
      t.uuid :auditable_id, null: false
      t.string :action, null: false
      t.jsonb :changed_fields, default: {}
      t.string :ip_address

      t.timestamps
    end

    add_index :audit_logs, [:auditable_type, :auditable_id]
    add_index :audit_logs, :action
  end
end
