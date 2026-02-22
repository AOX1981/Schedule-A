class CreateExpenseLines < ActiveRecord::Migration[8.1]
  def change
    create_table :expense_lines, id: :uuid do |t|
      t.references :receipt, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :transaction_display_id, null: false
      t.integer :line_number, null: false
      t.string :item, null: false
      t.decimal :cost, precision: 10, scale: 2, null: false
      t.string :tax_category
      t.decimal :writeoff_percent, precision: 5, scale: 2, default: 100.0
      t.decimal :writeoff_value, precision: 10, scale: 2

      t.timestamps
    end

    add_index :expense_lines, :transaction_display_id, unique: true
    add_index :expense_lines, [:receipt_id, :line_number], unique: true
    add_index :expense_lines, :tax_category
  end
end
