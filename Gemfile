source "https://rubygems.org"

gem "rails", "~> 8.1.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"

# Auth
gem "bcrypt", "~> 3.1.7"

# CORS
gem "rack-cors"

gem "tzinfo-data", platforms: %i[ windows jruby ]

# Background jobs
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false

# ActiveStorage image processing
gem "image_processing", "~> 1.2"

# OCR for receipt text extraction
gem "rtesseract"

# PDF generation
gem "matrix" # required by prawn on Ruby 3.1+
gem "prawn"
gem "prawn-table"

# CSV export (bundled gem in Ruby 3.4+)
gem "csv"

# JSON serialization
gem "alba"

# Pagination
gem "pagy"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end
