module LiquidVectorGraphic
  module Tags
    class QueryTag < FormTag
      tag_name :query_field

      private

      def default_date_format
        strftime_string || '%Y-%m-%d'
      end

      def default_datetime_format
        strftime_string || '%Y-%m-%dT%H:%M:%SZ'
      end
    end
  end
end
