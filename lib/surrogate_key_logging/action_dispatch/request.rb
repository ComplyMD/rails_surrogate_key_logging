# frozen_string_literal: true

module SurrogateKeyLogging
  module ActionDispatch
    module Request

      def filtered_query_string
        super.gsub(::ActionDispatch::Request::PAIR_RE) do |_|
          SurrogateKeyLogging.filter_parameters(::Regexp.last_match(1) => ::Regexp.last_match(2)).first.join('=')
        end
      end

    end
  end
end
