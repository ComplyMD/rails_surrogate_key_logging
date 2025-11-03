# frozen_string_literal: true

module SurrogateKeyLogging
  # Custom Parameter Filter for Rails 7.1 Compatibility
  #
  # Rails 7.1 changed how ParameterFilter handles callable masks, causing surrogate
  # objects to appear in logs instead of surrogate values. This implementation uses
  # a custom recursive traversal approach that works consistently across Rails versions
  # and supports all existing parameter format patterns from the README.
  class CustomParameterFilter
    def initialize(attrs, key_manager)
      @attrs = attrs
      @key_manager = key_manager
    end

    def filter(params)
      deep_filter(params, @attrs)
    end

    private

    def deep_filter(obj, attrs, current_path = [])
      case obj
      when Hash
        obj.each_with_object(obj.class.new) do |(key, value), filtered|
          new_path = current_path + [key]
          
          if should_filter?(key, new_path, attrs)
            filtered[key] = @key_manager.call(key, value, current_path).to_s
          else
            filtered[key] = deep_filter(value, attrs, new_path)
          end
        end
      when Array
        obj.map.with_index { |item, index| deep_filter(item, attrs, current_path + [index]) }
      else
        obj
      end
    end

    def should_filter?(key, path, attrs)
      attrs.any? do |attr|
        case attr
        when String, Symbol
          matches_string_pattern?(key, path, attr.to_s)
        when Regexp
          attr.match?(key.to_s)
        else
          false
        end
      end
    end

    def matches_string_pattern?(key, path, pattern)
      # Support existing formats from README:
      # :foo, 'another.foo', 'another[foo]'
      
      current_key = key.to_s
      
      # Direct key match: :foo
      return true if current_key == pattern
      
      # Dot notation: 'another.foo'
      if pattern.include?('.')
        dot_path = path.map(&:to_s).join('.')
        return true if dot_path == pattern
      end
      
      # Bracket notation: 'another[foo]'
      if pattern.include?('[') && pattern.include?(']')
        if path.length >= 2
          parent = path[-2].to_s
          child = path[-1].to_s
          bracket_pattern = "#{parent}[#{child}]"
          return true if bracket_pattern == pattern
        end
      end
      
      false
    end
  end
end
