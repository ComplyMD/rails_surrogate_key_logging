# frozen_string_literal: true

require 'rails'
require 'securerandom'

module SurrogateKeyLogging
  class Engine < ::Rails::Engine
    isolate_namespace SurrogateKeyLogging

    config.autoload_paths << root.join('lib')

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.assets false
      g.helper false
      g.templates.unshift File.expand_path('lib/templates', root)
    end

    rake_tasks do
      load 'tasks/surrogate_key_logging.rake'
      load 'tasks/key_store/active_record.rake'
    end

    initializer 'surrogate_key_logging.config' do |app|
      SurrogateKeyLogging.configure do |config|
        config.enabled = Rails.env.production? unless config.key?(:enabled)
        config.debug = !Rails.env.production? unless config.key?(:debug)
        config.key_prefix = '' unless config.key?(:key_prefix)
        config.key_for ||= -> (value) { "#{config.key_prefix}#{SecureRandom.uuid}" }
        config.cache = true unless config.key?(:cache)
        config.cache_key_for ||= -> (value) { value }
        config.key_ttl ||= 90.days
      end
    end

    initializer 'surrogate_key_logging.filter_parameters' do
      if SurrogateKeyLogging.config.enabled
      end
    end

    initializer 'surrogate_key_logging.logs' do
      if SurrogateKeyLogging.config.enabled
        ::ActiveRecord::LogSubscriber.detach_from(:active_record)
        ::SurrogateKeyLogging::ActiveRecord::LogSubscriber.attach_to(:active_record)
        ::ActiveSupport::LogSubscriber.detach_from(:action_controller)
        ::SurrogateKeyLogging::ActionController::LogSubscriber.attach_to(:action_controller)
        ::ActionDispatch::Request.include SurrogateKeyLogging::ActionDispatch::Request
      end
    end

    initializer 'surrogate_key_logging.middleware' do
      if SurrogateKeyLogging.config.enabled
        Rails.application.config.middleware.insert_before 0, Middleware
      end
    end

  end
end
