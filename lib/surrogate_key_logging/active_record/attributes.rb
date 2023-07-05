# frozen_string_literal: true

require 'active_support/concern'

module SurrogateKeyLogging
  module ActiveRecord
    module Attributes
      extend ::ActiveSupport::Concern

      class_methods do
        def surrogate_parent_names(*names)
          @surrogate_parent_names ||= [model_name.singular, model_name.plural]
          names.each do |name|
            @surrogate_parent_names << name.to_sym
            surrogate_attributes.each do |attr|
              SurrogateKeyLogging.add_param_to_filter(attr, name)
            end
          end
          @surrogate_parent_names
        end

        def surrogate_attributes(*attrs)
          @surrogate_attributes ||= []
          attrs.each do |attr|
            @surrogate_attributes << attr.to_sym
            surrogate_parent_names.each do |parent|
              SurrogateKeyLogging.add_param_to_filter(attr, parent)
            end
          end
          @surrogate_attributes
        end
      end

    end
  end
end
