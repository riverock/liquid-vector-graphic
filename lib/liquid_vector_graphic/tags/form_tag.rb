module LiquidVectorGraphic
  module Tags
    class NoNameOnFormTagError < Exception; end
    class InvalidMethodError < StandardError; end

    class FormTag < Solid::Tag
      tag_name :form_field

      attr_accessor :form_tag_options

      def display(form_tag_options)
        self.form_tag_options = form_tag_options

        add_to_form_stack!
        form_value || form_tag_options[:default]
      end

      def form_stack
        current_context.environments.first['_form_stack']
      end

      def valid_methods
        [
          :past_date,
          :past_datetime,
          :future_date,
          :future_datetime
        ]
      end

      def form_value
        if (tag_source = form_tag_options[:source])
          id = form_values[current_tag_name] || form_tag_options[:default]
          if (drop = find_source_value(tag_source, id))
            current_context.merge({current_tag_name => drop})
          end
          drop.present? ? (drop.try(:display_value) || '') : ''
        else
          form_values[current_tag_name]
        end
      end

      def find_source_value(tag_source, id)
        if id.present?
          FormOptions::Source.new(tag_source, parent).find(id)
        end
      end

      def form_values
        current_context.environments.first['_form_values'] || {}
      end

      def current_tag_name
        form_tag_options[:name].presence ||
          raise(NoNameOnFormTagError, "name key must be present on form_field")
      end

      def add_to_form_stack!
        form_stack << form_tag_options
      end

      def parent
        current_context.environments.first['_parent'] || {}
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
        calculated_date(:prev_day).strftime("%Y-%m-%dT%H:%M:%SZ")
      end

      def future_datetime
        calculated_date(:next_day).strftime("%Y-%m-%dT%H:%M:%SZ")
      end

      def raw_value
        form_values.fetch(current_tag_name) do
          form_tag_options[:default]
        end
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
