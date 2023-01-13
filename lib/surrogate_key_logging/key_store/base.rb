# frozen_string_literal: true

module SurrogateKeyLogging
  module KeyStore
    class Base

      def surrogate_for_value(key, value)
        raise NotImplementedError
      end

      def value_for_surrogate(key, surrogate)
        raise NotImplementedError
      end

      def save(key, value, surrogate)
        raise NotImplementedError
      end
      
    end
  end
end
