# frozen_string_literal: true

module SurrogateKeyLogging
  class Config < ::ActiveSupport::OrderedOptions
  end

  module Configuration
    extend ::ActiveSupport::Concern

    def surrogate_key_logging
      SurrogateKeyLogging.config
    end

  end
end
