# frozen_string_literal: true

module SurrogateKeyLogging
  module KeyStore
    class Base

      def get(value, generator)
        raise NotImplementedError
      end
      
    end
  end
end
