module LiquidVectorGraphic
  module Tags
    class FormTag < Solid::Tag
      tag_name :form

      attr_accessor :form_tag_options

      def display(form_tag_options)
        self.form_tag_options = form_tag_options

        add_to_form_stack!
      end

      def form_stack
        current_context.environments.first['_form_stack']
      end

      

      def add_to_form_stack!
        form_stack << form_tag_options
      end

    end
  end
end
