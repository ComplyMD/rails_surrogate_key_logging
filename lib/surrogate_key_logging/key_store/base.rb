# frozen_string_literal: true

module SurrogateKeyLogging
  module KeyStore
    class Base

      def surrogate_for_value(value)
        raise NotImplementedError
      end

      def value_for_surrogate(surrogate)
        raise NotImplementedError
      end

      def save(surrogate, value)
        raise NotImplementedError
      end
      
      def use(surrogate)
        raise NotImplementedError
      end
      
    end
  end
end
