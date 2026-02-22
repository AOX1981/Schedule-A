class UserSerializer
  include Alba::Resource

  attributes :id, :email, :full_name, :created_at, :updated_at
end
