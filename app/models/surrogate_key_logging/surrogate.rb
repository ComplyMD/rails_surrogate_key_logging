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

      def add(surrogate, value)
        s = new(key: surrogate, value: value, hashed_value: hash_value(value))
        s.save
      end

      def use(surrogate)
        where(key: surrogate).touch_all
      end
    end
  end
end
