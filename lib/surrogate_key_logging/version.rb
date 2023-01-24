# frozen_string_literal: true

module SurrogateKeyLogging

  module Version
    MAJOR = 0
    MINOR = 2
    PATCH = 1

  end

  VERSION = [
    Version::MAJOR,
    Version::MINOR,
    Version::PATCH,
  ].join('.').freeze

end
