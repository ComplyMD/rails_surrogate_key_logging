# frozen_string_literal: true

namespace :skl do
  namespace :key_store do
    namespace :active_record do
      namespace :db do |ns|
        %i[drop create setup migrate rollback seed version].each do |task_name|
          task task_name => :environment do
            Rake::Task["db:#{task_name}"].invoke
          end
        end
    
        namespace :migrate do
          %i[up down redo].each do |task_name|
            task task_name => :environment do
              Rake::Task["db:migrate:#{task_name}"].invoke
            end
          end
        end
    
        namespace :schema do
          %i[load dump].each do |task_name|
            task task_name => :environment do
              Rake::Task["db:schema:#{task_name}"].invoke
            end
          end
        end
    
        namespace :test do
          task prepare: :environment do
            Rake::Task['db:test:prepare'].invoke
          end
        end
    
        namespace :environment do
          task set: :environment do
            Rake::Task['db:environment:set'].invoke
          end
        end
    
        ns.tasks.each do |task|
          task.enhance ['skl:key_store:active_record:set_surrogate_key_logging_db_config'] do
            Rake::Task['skl:key_store:active_record:revert_surrogate_key_logging_db_config'].invoke
            Rake::Task['skl:key_store:active_record:set_surrogate_key_logging_db_config'].reenable
            Rake::Task['skl:key_store:active_record:revert_surrogate_key_logging_db_config'].reenable
          end
        end

        ns.tasks.each do |task|
          task.enhance ['skl:key_store:active_record:check_config'] do
            Rake::Task['skl:key_store:active_record:check_config'].reenable
          end
        end
      end
    
      task set_surrogate_key_logging_db_config: :environment do
        # save current vars
        @original_db_config = {
          env_schema: ENV['SCHEMA'],
          config: Rails.application.config.dup,
          ar_config: ActiveRecord::Base.
                       configurations.
                       configurations.inject({}) do |memo, db_config|
                         memo.merge(db_config.env_name => db_config.configuration_hash.stringify_keys)
                       end,
        }
    
        # set config variables for custom database
        db_dir = SurrogateKeyLogging::Engine.root.join('db')
        schema_path = Rails.root.join('db', "surrogate_key_logging_schema.#{Rails.application.config.active_record.schema_format}")
        ENV['SCHEMA'] = schema_path.to_s
        Rails.application.config.paths['db'] = [db_dir]
        Rails.application.config.paths['db/migrate'] = [db_dir.join('migrate')]
        Rails.application.config.paths['db/seeds'] = [db_dir.join('seeds.rb')]
        Rails.application.config.paths['config/database'] = [SurrogateKeyLogging::Engine.root.join('config', 'database.yml')]
        ActiveRecord::Base.configurations = ActiveRecord::Base.
                                              configurations.
                                              configurations.inject({}) do |memo, db_config|
                                                next memo unless db_config.env_name.start_with?('surrogate_key_logging_')
                                                memo.merge(db_config.env_name.sub(/^surrogate_key_logging_/, '') => db_config.configuration_hash.stringify_keys)
                                              end
        ActiveRecord::Base.establish_connection Rails.application.config.database_configuration[Rails.env]
      end
    
      task revert_surrogate_key_logging_db_config: :environment do
        # reset config variables to original values
        ENV['SCHEMA'] = @original_db_config[:env_schema]
        Rails.application.config = @original_db_config[:config]
        ActiveRecord::Base.configurations = @original_db_config[:ar_config]
        ActiveRecord::Base.establish_connection Rails.application.config.database_configuration[Rails.env]
      end

      task check_config: :environment do
        raise "SurrogateKeyLogging config.key_store must be set to :active_record for this task to function, it is currently set to `#{SurrogateKeyLogging.config.key_store.inspect}`" unless SurrogateKeyLogging.config.key_store == :active_record
      end
    end
  end
end
