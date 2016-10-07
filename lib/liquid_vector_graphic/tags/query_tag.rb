module LiquidVectorGraphic
  module Tags
    class QueryTag < FormTag
      tag_name :query_field

      # def form_value
      #   if (method = form_tag_options.delete(:method)) && raw_value.present?
      #     verify_and_call(method.to_sym)
      #   else
      #     super
      #   end
      # end

      private

      def default_date_format
        '%Y-%m-%d'
      end

      def default_datetime_format
        '%Y-%m-%dT%H:%M:%SZ'
      end
    end
  end
end
