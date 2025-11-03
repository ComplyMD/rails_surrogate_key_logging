# frozen_string_literal: true

require 'active_support'

# Container Module
module SurrogateKeyLogging
  extend ::ActiveSupport::Autoload

  autoload :ActionController
  autoload :ActionDispatch
  autoload :ActiveSupport
  autoload :ActiveRecord
  autoload :Config, 'surrogate_key_logging/configuration'
  autoload :Configuration
  autoload :Engine
  autoload :KeyManager
  autoload :KeyStore
  autoload :Middleware
  autoload :Version
  autoload :CustomParameterFilter

  require 'surrogate_key_logging/sidekiq' if defined?(::Sidekiq)

  @config = Config.new

  class << self

    attr_reader :config

    def configure
      yield config
    end

    def surrogate_attributes(*attrs)
      @surrogate_attributes ||= []
      attrs.each do |attr|
        @surrogate_attributes << attr.to_s
      end
      @surrogate_attributes
    end

    def reset
      reset! if config.cache
    end

    def reset!
      @key_manager = @parameter_filter = nil
    end

    def key_manager
      @key_manager ||= KeyManager.new
    end

    def parameter_filter
      @parameter_filter ||= filter_for_attributes(surrogate_attributes)
    end

    # Rails 6/7 Compatible Parameter Filtering
    # 
    # Rails 7.1 changed how ParameterFilter handles callable masks, causing surrogate
    # objects to appear in logs instead of surrogate values. This implementation uses
    # a custom recursive traversal approach that works consistently across Rails versions
    # and supports all existing parameter format patterns from the README.
    def filter_for_attributes(attrs)
      if config.enabled
        # Return a custom filter that handles all supported parameter patterns
        CustomParameterFilter.new(attrs, key_manager)
      else
        # Return a no-op filter when disabled
        ->(params) { params.dup }
      end
    end

    def key_store
      @key_store ||= KeyStore.get(config.key_store).new
    end

    def filter_parameters(params)
      parameter_filter.filter(params)
    end

    def surrogate_for(value)
      config.enabled ? key_manager.get(value) : value
    end

    def add_param_to_filter(attr, *parents)
      if parents.empty?
        surrogate_attributes attr.to_s
      else
        surrogate_attributes(
          "#{parents.join('.')}.#{attr}",
          "#{parents.first}#{parents[1..-1].map{|x|"[#{x}]"}.join('')}[#{attr}]",
          "#{parents.map{|x|"[#{x}]"}.join('')}[#{attr}]"
        )
      end
    end

  end

  require 'active_support/parameter_filter'
  KeyStore.eager_load!
  ::Rails::Application::Configuration.send(:include, Configuration)
  require 'surrogate_key_logging/engine'

end
