# frozen_string_literal: true

require 'action_controller/log_subscriber'

module SurrogateKeyLogging
  module ActionController
    class LogSubscriber < ::ActionController::LogSubscriber

      def start_processing(event)
        event.payload[:params] = SurrogateKeyLogging.filter_parameters event.payload[:params]
        super
      end

    end
  end
end
