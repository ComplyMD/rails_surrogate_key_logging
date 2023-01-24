# frozen_string_literal: true

module SurrogateKeyLogging
  module ActionDispatch
    module Request

      def filtered_parameters
        @filtered_parameters ||= ParamsFilter.call(super, self)
      end

      def filtered_query_string
        QueryStringFilter.call(super, self)
      end

    end
  end
end
