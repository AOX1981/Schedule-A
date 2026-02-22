class BusinessProfileSerializer
  include Alba::Resource

  attributes :id, :business_name, :ein, :business_type, :tax_year, :created_at, :updated_at
end
