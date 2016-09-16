module LiquidVectorGraphic
  class Template
    attr_accessor :template, :form_values

    # @param [File] a templatized Liquid SVG file to render
    # @note the file parameter can be any stream object.  Make sure to rewind before sending.
    def initialize(file)
      self.template = file.read
    end

    # @param [Hash<String>] send in a hash (with string keys) of output options
    # @option [Hash] '_form_values' a hash of k/v where k = field(:name from form_tag), v = the selected value from a filled out form.
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

    def grouped_form_fields_params
      grouped_fields = sorted_form_stack.map do |form_field|
        common_field_cleanup(form_field)
      end.group_by { |h| h.delete(:group_name) }
      grouped_fields = formtasticize_groups(grouped_fields.merge("Default" => grouped_fields.delete(nil)))
      sort_form_groups(grouped_fields)
    end

    def form_fields_params
      sorted_form_stack.map do |form_field|
        form_field = common_field_cleanup(form_field)
        form_field = remove_group_position_from(form_field)
        [form_field.delete(:name), **remove_group_name_from(form_field)]
      end
    end

    private

    def sort_form_groups(grouped_fields)
      new_grouped_fields = {}
      form_group_order.each do |g|
        k = g.keys.first
        grouped_fields[k].each { |v| v.last.delete(:group_position) }
        values = grouped_fields[k]
        new_grouped_fields.merge!({k => values})
      end
      new_grouped_fields
    end

    def form_group_order
      @form_group_order = begin
        names_and_positions = form_stack.map { |f| { f[:group_name] => f[:group_position] } }
        names_and_positions.keep_if { |k| k.values.first.present? }
        names_and_positions.push({ "Default" => 1000 }).uniq! { |group| group.keys }
        names_and_positions.sort_by { |z| z.values.first }
      end
    end

    def common_field_cleanup(form_field)
      fdup = form_field.dup
      fdup = apply_source_to(fdup)
      fdup = apply_value_to(fdup)
      fdup = apply_required_to(fdup)
      fdup = remove_position_from(fdup)
      fdup
    end

    def sorted_form_stack
      form_stack.sort_by do |form_field|
        [ position_for(form_field),
          form_field[:name] ]
      end
    end

    def apply_source_to(h)
      return h unless h.has_key?(:source)
      h.deep_merge!({ collection: FormOptions::Source.new(h.delete(:source)).form_options })
    end

    def apply_value_to(h)
      return apply_select_default_to(h) if h[:as] == 'select'
      return h unless form_values[h[:name]].present? || h[:default].present?
      default = h.delete(:default)
      h.deep_merge!({ input_html: { value: form_values[h[:name]] || default } })
    end

    def apply_required_to(h)
      return h unless h[:required].present?
      h.deep_merge!({ input_html: { required: h.delete(:required) } })
    end

    def apply_select_default_to(h)
      default = h.delete(:default)
      h.deep_merge!({ selected: form_values[h[:name]] || default })
    end

    def remove_position_from(h)
      h.delete(:position)
      h
    end

    def remove_group_position_from(h)
      h.delete(:group_position)
      h
    end

    def remove_group_name_from(h)
      h.delete(:group_name)
      h
    end

    def formtasticize_groups(groups)
      groups.inject({}) do |new_hash, array|
        new_hash.merge!({
          array[0] => array[1].map { |v| [v.delete(:name), **v] }
        })
      end
    end

    def parsed
      Liquid::Template.parse(template)
    end

    def position_for(form_field)
      return 1000 if form_field[:position].blank?
      form_field[:position].to_i
    end
  end
end
