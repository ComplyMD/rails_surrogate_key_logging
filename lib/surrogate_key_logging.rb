# frozen_string_literal: true

require 'active_support'

# Container Module
module SurrogateKeyLogging
  extend ActiveSupport::Autoload

  autoload :ActionController
  autoload :ActionDispatch
  autoload :ActiveSupport
  autoload :ActiveRecord
  autoload :Config, 'surrogate_key_logging/configuration'
  autoload :Configuration
  autoload :KeyManager
  autoload :KeyStore
  autoload :Middleware
  autoload :Engine
  autoload :Version

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
      @parameter_filter ||= ::ActiveSupport::ParameterFilter.new(surrogate_attributes, mask: key_manager)
    end

    def key_store
      @key_store ||= KeyStore.get(config.key_store).new
    end

    def filter_parameters(params)
      parameter_filter.filter params
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

  KeyStore.eager_load!
  ::Rails::Application::Configuration.send(:include, Configuration)
  require 'surrogate_key_logging/engine'

end
