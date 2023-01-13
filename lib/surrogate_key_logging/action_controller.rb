# frozen_string_literal: true

module SurrogateKeyLogging
  module ActionController
    extend ActiveSupport::Autoload

    autoload :LogSubscriber

  end
end
