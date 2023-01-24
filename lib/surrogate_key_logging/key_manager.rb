# frozen_string_literal: true

module SurrogateKeyLogging
  class KeyManager

    attr_reader :should_cache, :cache_key_for, :cache, :key_for

    delegate :key_store, to: SurrogateKeyLogging

    def initialize
      @should_cache = SurrogateKeyLogging.config.cache
      @cache_key_for = SurrogateKeyLogging.config.cache_key_for
      @cache = {}
      @key_for = SurrogateKeyLogging.config.key_for
    end

    def get(value)
      if should_cache
        get_cached(value)
      else
        get_non_cached(value)
      end
    end

    def get_cached(value)
      @cache[cache_key_for.call(value)] ||= get_non_cached(value)
    end

    def get_non_cached(value)
      stored = key_store.surrogate_for_value(value)
      return stored if stored.present?
      surrogate = key_for.call(value)
      key_store.save(surrogate, value)
      surrogate
    end
    
    def call(_key, value, _parents = [], _original_params = nil)
      surrogate = get(value)
      Rails.logger.tagged('SurrogateKeyLogging') { Rails.logger.info "Surrogate: `#{surrogate}`, value: `#{value}`" } if SurrogateKeyLogging.config.debug
      surrogate
    end

  end
end
