# frozen_string_literal: true

module SurrogateKeyLogging
  module ActionDispatch
    class QueryStringFilter

      class << self
        def call(qs, req = nil)
          new(qs, req).filtered
        end
      end

      attr_reader :qs, :req

      def initialize(qs, req = nil)
        @qs = qs
        @req = req
      end

      def path_params
        @path_params ||= begin
          req.routes.recognize_path_with_request(req, req.path, {})
        rescue
          {}
        end
      end

      def controller_class
        @controller_class = req.controller_class_for(path_params[:controller])
      end

      def filterable_params
        @filterable_params ||= if controller_class.respond_to?(:surrogate_params)
          surrogate_params = controller_class.surrogate_params
          surrogate_params[path_params[:action]] + surrogate_params['*']
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
        @filtered ||= begin
          parts = qs.split(/([&;])/)
          filtered_parts = parts.map do |part|
            if part.include?("=")
              key, value = part.split("=", 2)
              params_filter.filter(key => value).first.join("=")
            else
              part
            end
          end
          filtered_parts.join("")
        end
      end

    end
  end
end
