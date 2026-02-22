Rails.application.config.after_initialize do
  if Rails.env.production?
    required_vars = %w[
      DATABASE_URL
      SECRET_KEY_BASE
      RAILS_MASTER_KEY
    ]

    missing = required_vars.select { |var| ENV[var].blank? }
    if missing.any?
      raise "Missing required environment variables: #{missing.join(', ')}"
    end
  end
end
