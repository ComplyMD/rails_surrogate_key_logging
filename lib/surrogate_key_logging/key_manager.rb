module SurrogateKeyLogging
  class KeyManager
    def call(key, value, parents = [], original_params = nil)
      surrogate = "SK#{Digest::SHA512.hexdigest(value.to_s)}"
      puts "surrogate for key: `#{key}`, value: `#{value}`, surrogate: `#{surrogate}`"
      surrogate
    end
  end
end