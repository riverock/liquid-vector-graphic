module LiquidVectorGraphic
  module Tags
    class FormTag < Solid::Tag
      tag_name :form

      attr_accessor :form_values

      def display(form_values)
        self.form_values = form_values

        add_to_form_stack!
      end

      def form_stack
        current_context.environments.first['_form_stack']
      end

      def add_to_form_stack!
        form_stack << form_values
      end

    end
  end
end
