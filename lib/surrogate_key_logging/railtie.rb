# frozen_string_literal: true

require 'rails'

module SurrogateKeyLogging
  class Railtie < Rails::Railtie
    railtie_name :surrogate_key_logging

    initializer 'surrogate_key_logging.filter_parameters' do
    end

    initializer 'surrogate_key_logging.logs' do
      ::ActiveRecord::LogSubscriber.detach_from(:active_record)
      ::SurrogateKeyLogging::ActiveRecord::LogSubscriber.attach_to(:active_record)
      ::ActiveSupport::LogSubscriber.detach_from(:action_controller)
      ::SurrogateKeyLogging::ActionController::LogSubscriber.attach_to(:action_controller)
      ::ActionDispatch::Request.include SurrogateKeyLogging::ActionDispatch::Request
    end

    initializer 'surrogate_key_logging.middleware' do
      Rails.application.config.middleware.insert_before 0, Middleware
    end

  end
end
