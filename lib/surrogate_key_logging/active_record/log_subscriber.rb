# frozen_string_literal: true

module SurrogateKeyLogging
  module ActiveRecord
    class LogSubscriber < ::ActiveRecord::LogSubscriber

      def sql(event) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        self.class.runtime += event.duration
        return unless logger.debug?

        payload = event.payload

        return if IGNORE_PAYLOAD_NAMES.include?(payload[:name])

        name  = "#{payload[:name]} (#{event.duration.round(1)}ms)"
        name  = "CACHE #{name}" if payload[:cached]
        sql   = payload[:sql]
        binds = nil

        name_match = /([A-Za-z]+) (Load|Update|Cache)/.match(payload[:name])
        model = if name_match && name_match[1] && ::ActiveRecord::Base.descendants.map(&:to_s).include?(name_match[1])
                  name_match[1].safe_constantize
                end

        if payload[:binds]&.any?
          casted_params = type_casted_binds(payload[:type_casted_binds])

          binds = []
          payload[:binds].each_with_index do |attr, i|
            binds << render_bind(attr, casted_params[i], payload, model)
          end
          binds = binds.inspect
          binds.prepend('  ')
        end

        name = colorize_payload_name(name, payload[:name])
        sql  = color(sql, sql_color(sql), true) if colorize_logging

        debug "  #{name}  #{sql}#{binds}"
      end

      private

        def basic_parameter_filter
          @basic_parameter_filter ||= ::ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
        end

        def type_casted_binds(casted_binds)
          casted_binds.respond_to?(:call) ? casted_binds.call : casted_binds
        end

        def render_bind(attr, value, _payload, model) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          case attr
          when ActiveModel::Attribute
            value = "<#{attr.value_for_database.to_s.bytesize} bytes of binary data>" if attr.type.binary? && attr.value
          when Array
            attr = attr.first
          else
            attr = nil
          end

          attr_name = attr&.name
          if model && attr_name && model.respond_to?(:surrogate_attributes) && model.surrogate_attributes.include?(attr_name.to_sym)
            value = SurrogateKeyLogging.key_manager.call(attr_name, value, model.to_s.underscore)
          elsif attr_name
            value = basic_parameter_filter.filter(attr_name => value)[attr_name]
          end
          [attr_name, value]
        end

    end
  end
end
