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

    def get(key, value)
      if should_cache
        get_cached(key, value)
      else
        get_non_cached(key, value)
      end
    end

    def get_cached(key, value)
      @cache[cache_key_for.call(key, value)] ||= get_non_cached(key, value)
    end

    def get_non_cached(key, value)
      stored = key_store.surrogate_for_value(key, value)
      return stored if stored.present?
      surrogate = key_for.call(key, value)
      key_store.save(key, value, surrogate)
      surrogate
    end
    
    def call(key, value, _parents = [], _original_params = nil)
      surrogate = get(key, value)
      puts "surrogate for key: `#{key}`, value: `#{value}`, surrogate: `#{surrogate}`"
      surrogate
    end

  end
end
