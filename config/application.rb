require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module ScheduleA
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    # UUID primary keys
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    # Force SSL in production
    config.force_ssl = true if Rails.env.production?

    # All timestamps in UTC
    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc
  end
end
