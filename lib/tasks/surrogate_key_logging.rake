# frozen_string_literal: true

namespace :skl do
  task clear: :environment do
    Rake::Task["skl:key_store:#{SurrogateKeyLogging.config.key_store}:clear"].invoke
  end

  namespace :clear do
    task stale: :environment do
      Rake::Task["skl:key_store:#{SurrogateKeyLogging.config.key_store}:clear:stale"].invoke
    end
  end
end
