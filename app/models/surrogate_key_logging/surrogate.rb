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
        begin
          s = new(key: surrogate, value: value, hashed_value: hash_value(value))
          s.save
        rescue => e
          Rails.logger.tagged('SurrogateKeyLogging') { Rails.logger.error "Surrogate creation failed for: `#{surrogate}`, value: `#{value}`" } if SurrogateKeyLogging.config.debug
          Rails.logger.tagged('SurrogateKeyLogging') { Rails.logger.error "Exception on surrogate info creation: `#{e.message}`" }
        end
      end

      def use(surrogate)
        where(key: surrogate).touch_all
      end
    end
  end
end
