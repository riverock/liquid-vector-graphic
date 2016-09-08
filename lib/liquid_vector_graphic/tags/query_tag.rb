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

      def past_date
        calculated_date(:prev_day).strftime("%Y-%m-%d")
      end

      def future_date
        calculated_date(:next_day).strftime("%Y-%m-%d")
      end

      def past_datetime
        calculated_date(:prev_day).strftime("%Y-%m-%dT%H:%M:%S")
      end

      def future_datetime
        calculated_date(:next_day).strftime("%Y-%m-%dT%H:%M:%S")
      end

      def raw_value
        form_values[current_tag_name] || raise(Exception)
      end

      def base_date
        current_context.environments.first['_base_date']
      end

      def calculated_date(operation)
        (base_date || Date.today).send(operation, raw_value.to_i)
      end
    end
  end
end
