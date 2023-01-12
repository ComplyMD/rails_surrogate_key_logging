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
