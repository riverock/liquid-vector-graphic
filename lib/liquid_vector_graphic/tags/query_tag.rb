module LiquidVectorGraphic
  module Tags
    class QueryTag < FormTag
      tag_name :query_field

      # Due to a bug in quasar, the times need to be in Zulu time.
      def past_datetime
        calculated_date(:prev_day).to_datetime.utc.strftime(datetime_format)
      end

      def future_datetime
        calculated_date(:next_day).to_datetime.utc.strftime(datetime_format)
      end

      private

      def date_format
        strftime_string || '%Y-%m-%d'
      end

      def datetime_format
        strftime_string || '%Y-%m-%dT%H:%M:%SZ'
      end
    end
  end
end
