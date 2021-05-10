require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module Lightsaber
  class Application < Rails::Application
    config.assets.quiet = true

    config.generators do |generate|
      generate.helper false
      generate.javascripts false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
    end

    config.action_controller.action_on_unpermitted_parameters = :raise
    config.load_defaults 5.2
    config.generators.system_tests = nil
    config.active_job.queue_adapter = :delayed_job

    config.time_zone = 'Brasilia'
    config.i18n.default_locale = 'pt-BR'

    # layouts devise
    config.to_prepare do
      Devise::SessionsController.layout 'login'
      Devise::RegistrationsController.layout proc { user_signed_in? ? 'application' : 'login' } # editando perfil / criando conta
      Devise::ConfirmationsController.layout 'login'
      Devise::PasswordsController.layout 'login'
      Devise::Mailer.layout 'mailer'
    end

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end
  end
end
