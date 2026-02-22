class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :nickname, null: false
      t.string :last4, null: false, limit: 4
      t.string :account_type, default: "credit_card"

      t.timestamps
    end

    add_index :accounts, [:user_id, :last4]
  end
end
