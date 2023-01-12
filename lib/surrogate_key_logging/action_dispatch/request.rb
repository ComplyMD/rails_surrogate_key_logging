module SurrogateKeyLogging
  module ActionDispatch

    module Request
      def filtered_query_string
        super.gsub(::ActionDispatch::Request::PAIR_RE) do |_|
          SurrogateKeyLogging.filter_parameters($1 => $2).first.join("=")
        end
      end
    end

  end
end
