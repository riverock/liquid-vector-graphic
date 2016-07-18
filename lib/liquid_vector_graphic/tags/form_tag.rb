module LiquidVectorGraphic
  module Tags
    class FormTag < Solid::Tag
      tag_name :form

      attr_accessor :form_tag_options

      def display(form_tag_options)
        self.form_tag_options = form_tag_options

        add_to_form_stack!
        form_value || form_tag_options[:default]
      end

      def form_stack
        current_context.environments.first['_form_stack']
      end

      def form_value
        form_values[current_tag_name]
      end

      def form_values
        current_context.environments.first['_form_values'] || {}
      end

      def current_tag_name
        form_tag_options[:name].presence || raise(Exception)
      end

      def add_to_form_stack!
        form_stack << form_tag_options
      end

    end
  end
end
