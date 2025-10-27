# frozen_string_literal: true

module SurrogateKeyLogging
  class Surrogate < ApplicationRecord
    class << self
      def hash_value(value)
        Digest::SHA512.hexdigest value.to_s
      end

      def value_for_surrogate(surrogate)
        where(key: surrogate).select(:value).first&.value
      end

      def surrogate_for_value(value)
        where(hashed_value: hash_value(value)).select(:key).first&.key
      end

      def use(surrogate)
        where(key: surrogate).touch_all
      end

      def find_or_create_surrogate_for_value(value, key_for)
        hashed_value = hash_value(value)
        upsert_all([{key: key_for.call(value), value: value, hashed_value: hashed_value}], update_only: 'updated_at')
        where(hashed_value: hashed_value).select(:key).first.key
      end

    end

    # Ensure Surrogate instance shows the key when logged as a string
    def to_s
      key.to_s
    end

    # Provide detailed inspection for debugging
    def inspect
      value_preview = value.to_s.length > 50 ? "#{value.to_s[0..47]}..." : value.to_s
      "#<#{self.class.name} key=#{key.inspect} value=#{value_preview.inspect}>"
    end

  end
end
