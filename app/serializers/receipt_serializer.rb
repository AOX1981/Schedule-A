class ReceiptSerializer
  include Alba::Resource

  attributes :id, :receipt_number, :store_name, :city, :state,
             :transaction_date, :transaction_time, :total_amount,
             :designation, :source, :status, :extracted_data,
             :created_at, :updated_at

  attribute :image_url do |receipt|
    if receipt.image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(receipt.image, only_path: true)
    end
  end

  attribute :account_last4 do |receipt|
    receipt.account&.last4
  end

  attribute :business_profile_id do |receipt|
    receipt.business_profile_id
  end

  many :expense_lines, resource: ExpenseLineSerializer
end
