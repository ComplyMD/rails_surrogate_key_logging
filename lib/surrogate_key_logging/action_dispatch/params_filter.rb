# frozen_string_literal: true

module SurrogateKeyLogging
  module ActionDispatch
    class ParamsFilter

      class << self
        def call(params, req = nil)
          new(params, req).filtered
        end
      end

      attr_reader :params, :req
      
      def initialize(params, req = nil)
        @params = params
        @req = req
      end

      def filterable_params
        @filterable_params ||= if req.controller_class.respond_to?(:surrogate_params)
          surrogate_params = req.controller_class.surrogate_params
          surrogate_params[params[:action]] + surrogate_params['*']
        else
          []
        end
      end

      def params_filter
        return @params_filter if @params_filter
        attrs = SurrogateKeyLogging.parameter_filter.instance_variable_get(:@filters).dup
        attrs += filterable_params
        @params_filter = SurrogateKeyLogging.filter_for_attributes(attrs)
      end

      def filtered
        @filtered ||= params_filter.filter params
      end

    end
  end
end
