module LiquidVectorGraphic
  class Template
    attr_accessor :template, :form_values

    # @param [File] a templatized Liquid SVG file to render
    # @note the file parameter can be any stream object.  Make sure to rewind before sending.
    def initialize(file)
      self.template = file.read
    end

    # @param [Hash<String>] send in a hash (with string keys) of output options
    # @example Render with arbitrary information sent to template
    #   render('person' => { 'first_name' => 'Nic', 'last_name' => 'Boie' })
    #   will allow the template to interpolate {{ person.first_name }} and {{ person.last_name }}
    def render(opts = {})
      self.form_values = opts['_form_values'] || {}
      parsed.render(opts.merge('_form_stack' => form_stack))
    end

    def form_stack
      @form_stack ||= []
    end

    def form_fields_params
      form_stack.map do |form|
        fdup = form.dup
        fdup = apply_source_to(fdup)
        fdup = apply_value_to(fdup)
        [fdup.delete(:name), **fdup]
      end
    end

    private

    def apply_source_to(h)
      return h unless h.has_key?(:source)
      h.merge!({ collection: FormOptions::Source.new(h.delete(:source)).form_options })
    end

    def apply_value_to(h)
      return h unless form_values[h[:name]].present? || h[:default].present?
      default = h.delete(:default)
      h.merge!({ input_html: { value: form_values[h[:name]] || default } })
    end

    def parsed
      Liquid::Template.parse(template)
    end
  end

end
