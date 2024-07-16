# frozen_string_literal: true

if defined?(::Sidekiq)
  module Sidekiq
    if defined?(Worker)
      module Worker::ClassMethods
        def surrogate_params(*attrs)
          @surrogate_params ||= []
          attrs.each do |attr|
            @surrogate_params << attr.to_sym
          end
          @surrogate_params
        end
      end
    end
  end
end

module SurrogateKeyLogging
  class SidekiqMiddleware
    include Sidekiq::ServerMiddleware

    def call(instance, job_hash, queue, &block)
      ::Sidekiq::Context.with(context_for(job_hash), &block)
      SurrogateKeyLogging.reset
    end

    def context_for(job_hash)
      hash = job_hash.stringify_keys
      hash['args'] = {}

      if job_hash.key?('args')
        begin
          klass = hash['class'].constantize
          perform = klass.instance_method(:perform)
          params = perform.parameters
          params.each_with_index do |param, i|
            hash['args'][param.last] = job_hash['args'][i]
          end
          hash['args'] = SurrogateKeyLogging.filter_for_attributes(klass.surrogate_params).filter(hash['args'])
        rescue NameError # TODO: Add support for Sidekiq::Extensions::DelayedMailer (ApplicationMailer.delay.some_mail) and Sidekiq::Extensions::Delayed (SomeClass.delay.some_method)
        end
      end
      hash
    end

  end
end
