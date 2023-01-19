# frozen_string_literal: true

module SurrogateKeyLogging
  module KeyStore

    class ActiveRecord < Base

      attr_reader :model

      def initialize
        if SurrogateKeyLogging.config.key?(:model) && SurrogateKeyLogging.config.model.present?
          raise 'SurrogateKeyLogging::KeyStore::ActiveRecord config.model must descend from ActiveRecord::Base' unless SurrogateKeyLogging.config <= ::ActiveRecord::Base
          @model = SurrogateKeyLogging.config.model
        else
          @model = SurrogateKeyLogging::Surrogate
        end
      end

      def surrogate_for_value(value)
        key = model.surrogate_for_value(value)
        use(key)
        key
      end

      def value_for_surrogate(surrogate)
        model.value_for_surrogate(surrogate)
      end

      def save(surrogate, value)
        model.add(surrogate, value)
      end

      def use(surrogate)
        model.use(surrogate)
      end

    end

    add(:active_record, ActiveRecord)

  end
end
