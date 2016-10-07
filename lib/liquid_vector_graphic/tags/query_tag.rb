module LiquidVectorGraphic
  module Tags
    class QueryTag < FormTag
      tag_name :query_field

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
