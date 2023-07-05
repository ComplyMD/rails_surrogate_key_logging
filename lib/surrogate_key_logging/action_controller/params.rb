# frozen_string_literal: true

require 'active_support/concern'

module SurrogateKeyLogging
  module ActionController
    module Params
      extend ::ActiveSupport::Concern

      class_methods do
        def surrogate_params(*params, action: '*')
          @surrogate_params ||= ::ActiveSupport::HashWithIndifferentAccess.new {|h,k| h[k] = [] }
          params.each do |param|
            param = param.to_s
            @surrogate_params[action] << param
            if param.include?('.')
              dots = param.split('.')
              @surrogate_params[action] << [dots.first, dots[1..-1].map{|p| "[#{p}]"}].compact.join('')
              @surrogate_params[action] << URI.encode_www_form_component(@surrogate_params[action].last)
              @surrogate_params[action] << dots.map{|p| "[#{p}]"}.join('')
              @surrogate_params[action] << URI.encode_www_form_component(@surrogate_params[action].last)
            elsif param.include?('[') && param.include?(']')
              @surrogate_params[action] << URI.encode_www_form_component(param)
            else
              @surrogate_params[action] << param
            end
          end
          @surrogate_params
        end
      end

    end
  end
end
