# frozen_string_literal: true

module SurrogateKeyLogging
  module KeyStore
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Base
      autoload :Redis
    end

    @map = {}.with_indifferent_access

    class << self
      attr_reader :map

      def get(key_store)
        map[key_store] || raise("SurrogateKeyLogging unknown key_store: `#{key_store}`")
      end

      def add(name, klass)
        map[name] = klass
      end

    end

  end
end
