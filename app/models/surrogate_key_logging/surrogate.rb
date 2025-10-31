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
  end
end
