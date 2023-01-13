# frozen_string_literal: true

module SurrogateKeyLogging
  module KeyStore
    class Redis < Base
      attr_reader :client

      def initialize
        @client = SurrogateKeyLogging.config.redis_client
        raise 'SurrogateKeyLogging::KeyStore::Redis missing config.redis_client' unless @client.present?
      end

      def surrogate_for_value(key, value)
        puts "surrogate_for_value(#{key}, #{value})"
      end

      def value_for_surrogate(key, surrogate)
        puts "value_for_surrogate(#{key}, #{surrogate})"
      end

      def save(key, value, surrogate)
        puts "save(#{key}, #{value}, #{surrogate})"
      end
      
    end

    add(:redis, Redis)

  end
end
