require 'rails'

module SurrogateKeyLogging
  class Railtie < Rails::Railtie
    railtie_name :surrogate_key_logging

    initializer 'surrogate_key_logging.filter_parameters' do
      puts 'surrogate_key_logging.filter_parameters'
    end

    initializer 'surrogate_key_logging.logs' do
      puts 'surrogate_key_logging.logs'
      ::ActiveRecord::LogSubscriber.detach_from(:active_record)
      ::SurrogateKeyLogging::ActiveRecord::LogSubscriber.attach_to(:active_record)
      ::ActiveSupport::LogSubscriber.detach_from(:action_controller)
      ::SurrogateKeyLogging::ActionController::LogSubscriber.attach_to(:action_controller)
      binding.pry
      ::ActionDispatch::Request.send(:include, SurrogateKeyLogging::ActionDispatch::Request)
    end

    initializer 'surrogate_key_logging.middleware' do
      puts 'surrogate_key_logging.middleware'
      Rails.application.config.middleware.insert_before 0, Middleware
    end

  end
end
