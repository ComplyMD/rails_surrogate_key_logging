# frozen_string_literal: true

module SurrogateKeyLogging
  module KeyStore

    class ActiveRecord < Base

      attr_reader :model, :key_for

      def initialize
        if SurrogateKeyLogging.config.key?(:model) && SurrogateKeyLogging.config.model.present?
          raise 'SurrogateKeyLogging::KeyStore::ActiveRecord config.model must descend from ActiveRecord::Base' unless SurrogateKeyLogging.config <= ::ActiveRecord::Base
          @model = SurrogateKeyLogging.config.model
        else
          @model = SurrogateKeyLogging::Surrogate
        end
        @key_for = SurrogateKeyLogging.config.key_for
      end

      def get(value)
        _get = -> { model.find_or_create_surrogate_for_value(value, key_for) }
        if SurrogateKeyLogging.config.debug
          _get.call
        else
          ::ActiveRecord::Base.logger.silence { _get.call }
        end
      end

    end

    add(:active_record, ActiveRecord)

  end
end
