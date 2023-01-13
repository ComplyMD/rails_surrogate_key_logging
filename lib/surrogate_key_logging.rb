# frozen_string_literal: true

require 'active_support'

# Container Module
module SurrogateKeyLogging
  extend ActiveSupport::Autoload

  autoload :Railtie
  autoload :Version
  autoload :ActionController
  autoload :ActionDispatch
  autoload :ActiveSupport
  autoload :ActiveRecord
  autoload :KeyManager
  autoload :Middleware

  class << self
    def surrogate_attributes(*attrs)
      @surrogate_attributes ||= []
      attrs.each do |attr|
        @surrogate_attributes << attr.to_s
      end
      @surrogate_attributes
    end

    def reset
      @key_manager = @parameter_filter = nil
    end

    def key_manager
      @key_manager ||= KeyManager.new
    end

    def parameter_filter
      @parameter_filter ||= ::ActiveSupport::ParameterFilter.new(surrogate_attributes, mask: key_manager)
    end

    def filter_parameters(params)
      parameter_filter.filter params
    end

    def add_param_to_filter(attr, parent = nil)
      if parent.nil?
        surrogate_attributes attr.to_s
      else
        surrogate_attributes(
          "#{parent.to_s}.#{attr.to_s}",
          "#{parent.to_s}[#{attr.to_s}]",
          "[#{parent.to_s}][#{attr.to_s}]",
        )
      end
    end

  end

end

require 'surrogate_key_logging/railtie'
