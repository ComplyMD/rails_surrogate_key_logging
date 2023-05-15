# frozen_string_literal: true

module SurrogateKeyLogging
  class Middleware

    def initialize(app)
      @app = app
    end

    def call(env)
      SurrogateKeyLogging.reset
      @app.call(env)
    end

  end
end
