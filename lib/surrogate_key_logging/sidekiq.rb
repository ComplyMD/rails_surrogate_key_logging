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

    if defined?(JobLogger)
      class JobLogger
        alias_method :job_hash_context__before_surrogate_key_logging, :job_hash_context
        def job_hash_context(job_hash)
          hash = job_hash_context__before_surrogate_key_logging(job_hash).stringify_keys
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

  end
end
