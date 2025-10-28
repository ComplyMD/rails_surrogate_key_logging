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
      @last_surrogate = nil
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
      @last_surrogate = surrogate # Track the most recent surrogate for to_s
      Rails.logger.tagged('SurrogateKeyLogging') { Rails.logger.info "Surrogate: `#{surrogate}`, value: `#{value}`" } if SurrogateKeyLogging.config.debug
      surrogate
    end

    # Ensure KeyManager instance shows the actual surrogate value when logged
    # This fixes Rails 7.1 behavior where the mask object itself gets logged
    def to_s
      @last_surrogate&.to_s || "[FILTERED]"
    end

    # Provide detailed inspection for debugging
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} cache_size=#{cache.size} should_cache=#{should_cache} last_surrogate=#{@last_surrogate}>"
    end

  end
end
