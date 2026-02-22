class CreateReceipts < ActiveRecord::Migration[8.1]
  def change
    create_table :receipts, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :business_profile, foreign_key: true, type: :uuid
      t.references :account, foreign_key: true, type: :uuid
      t.integer :receipt_number, null: false
      t.string :store_name
      t.string :city
      t.string :state
      t.date :transaction_date
      t.string :transaction_time
      t.decimal :total_amount, precision: 10, scale: 2
      t.string :designation, null: false, default: "business"
      t.string :source, null: false, default: "upload"
      t.string :status, null: false, default: "pending"
      t.text :raw_ocr_text
      t.jsonb :extracted_data, default: {}

      t.timestamps
    end

    add_index :receipts, [:user_id, :receipt_number], unique: true
    add_index :receipts, :status
    add_index :receipts, :designation
  end
end
