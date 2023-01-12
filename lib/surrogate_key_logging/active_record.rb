module SurrogateKeyLogging
  module ActiveRecord
    extend ActiveSupport::Autoload

    autoload :SurrogateAttributes
    autoload :LogSubscriber
    
  end
end