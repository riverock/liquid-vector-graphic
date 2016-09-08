module LiquidVectorGraphic
  module Tags
    class InvalidMethodError < StandardError; end

    class QueryTag < FormTag
      tag_name :query_field

      def valid_methods
        [
          :past_date,
          :past_datetime,
          :future_date,
          :future_datetime
        ]
      end

      def form_value
        if method = form_tag_options.delete(:method)
          verify_and_call(method.to_sym)
        else
          super
        end
      end

      private

      def verify_and_call(method)
        if valid_methods.include?(method)
          send(method)
        else
          raise InvalidMethodError, "The method specified is not supported."
        end
      end
    end
  end
end
