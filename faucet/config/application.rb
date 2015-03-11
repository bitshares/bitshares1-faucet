require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"
require 'ostruct'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BitSharesFaucet
  class Application < Rails::Application

    config.generators do |g|
      g.template_engine :haml
      g.assets false
      g.javascripts false
      g.helper false
      g.view_specs false
      g.routing_specs false
      g.request_specs false
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.

    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.action_dispatch.perform_deep_munge = false

    config.action_dispatch.default_headers = { } # needed for jsonp

    bitshares_conf = ERB.new(File.read("#{Rails.root}/config/bitshares.yml")).result
    config.send("bitshares=", OpenStruct.new(YAML.load(bitshares_conf)))

    config.cache_store = :memory_store, {size: 16.megabytes}

    config.action_mailer.default_url_options = {host: Rails.application.config.bitshares.default_url, port: Rails.application.config.bitshares.default_port}

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
        address: Rails.application.config.bitshares.mandrill['host'],
        port: 587,
        user_name: Rails.application.config.bitshares.mandrill['user_name'],
        password: Rails.application.config.bitshares.mandrill['password'],
        authentication: 'plain',
        enable_starttls_auto: true
    }

    routes.default_url_options = config.action_mailer.default_url_options
  end
end
