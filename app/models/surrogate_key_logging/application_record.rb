# frozen_string_literal: true

module SurrogateKeyLogging
  class ApplicationRecord < ::ActiveRecord::Base
    self.abstract_class = true

    def self.table_name
      "#{Rails.application.config.database_configuration["surrogate_key_logging_#{Rails.env}"]['database']}.#{compute_table_name}"
    end

  end

  class << self
    def table_name_prefix; end
  end

end
