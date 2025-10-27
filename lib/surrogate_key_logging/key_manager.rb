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
      return if value.blank?
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
      key_store.get(value)
    end

    def call(_key, value, _parents = [], _original_params = nil)
      return "" if value.blank?
      return value unless SurrogateKeyLogging.config.enabled
      surrogate = get(value)
      Rails.logger.tagged('SurrogateKeyLogging') { Rails.logger.info "Surrogate: `#{surrogate}`, value: `#{value}`" } if SurrogateKeyLogging.config.debug
      surrogate
    end

    # Ensure KeyManager instance shows meaningful representation when logged
    def to_s
      "[SurrogateKeyLogging::KeyManager cache_size=#{cache.size} enabled=#{SurrogateKeyLogging.config.enabled}]"
    end

    # Provide detailed inspection for debugging
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} cache_size=#{cache.size} should_cache=#{should_cache}>"
    end

  end
end
