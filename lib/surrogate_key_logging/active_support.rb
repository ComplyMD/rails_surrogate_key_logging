# frozen_string_literal: true

require 'active_support/parameter_filter'

# Add ability for @mask to be a class/instance/lambda/proc
module ActiveSupport
  module ParameterFilter
    class CompiledFilter

      def value_for_key(key, value, parents = [], original_params = nil) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        parents.push(key) if deep_regexps
        if regexps.any? { |r| r.match?(key.to_s) }
          value = @mask.respond_to?(:call) ? @mask.call(key, value, parents, original_params) : @mask
        elsif deep_regexps && (joined = parents.join('.')) && deep_regexps.any? { |r| r.match?(joined) } # rubocop:disable Lint/DuplicateBranch
          value = @mask.respond_to?(:call) ? @mask.call(key, value, parents, original_params) : @mask
        elsif value.is_a?(Hash)
          value = call(value, parents, original_params)
        elsif value.is_a?(Array)
          # If we don't pop the current parent it will be duplicated as we
          # process each array value.
          parents.pop if deep_regexps
          value = value.map { |v| value_for_key(key, v, parents, original_params) }
          # Restore the parent stack after processing the array.
          parents.push(key) if deep_regexps
        elsif blocks.any?
          key = key.dup if key.duplicable?
          value = value.dup if value.duplicable?
          blocks.each { |b| b.arity == 2 ? b.call(key, value) : b.call(key, value, original_params) }
        end
        parents.pop if deep_regexps
        value
      end

    end
  end
end
