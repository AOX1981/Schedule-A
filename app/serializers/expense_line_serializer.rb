class ExpenseLineSerializer
  include Alba::Resource

  attributes :id, :transaction_display_id, :line_number, :item, :cost,
             :tax_category, :writeoff_percent, :writeoff_value,
             :created_at, :updated_at

  attribute :receipt_id do |line|
    line.receipt_id
  end

  attribute :store_name do |line|
    line.receipt.store_name
  end

  attribute :transaction_date do |line|
    line.receipt.transaction_date
  end

  attribute :acct_last4 do |line|
    line.receipt.account&.last4
  end
end
