class AccountSerializer
  include Alba::Resource

  attributes :id, :nickname, :last4, :account_type, :created_at, :updated_at
end
