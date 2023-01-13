# frozen_string_literal: true

module SurrogateKeyLogging
  module ActiveRecord
    extend ActiveSupport::Autoload

    autoload :Attributes
    autoload :LogSubscriber

  end
end
