# frozen_string_literal: true

module SurrogateKeyLogging
  module ActionDispatch
    extend ActiveSupport::Autoload

    autoload :ParamsFilter
    autoload :QueryStringFilter
    autoload :Request

  end
end
