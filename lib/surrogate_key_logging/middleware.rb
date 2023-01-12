module SurrogateKeyLogging
  class Middleware
    attr_reader :app

    def initialize(app)
      @app = app
      puts "surrogate new"
    end

    def call(env)
      SurrogateKeyLogging.reset
      @app.call(env)
    end

  end
end