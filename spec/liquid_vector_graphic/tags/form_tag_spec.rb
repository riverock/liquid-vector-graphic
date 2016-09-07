describe LiquidVectorGraphic::Tags::FormTag do
  describe '#display' do
    context 'value set' do
      let(:template) do
        Solid::Template.parse(%(
          {% form_field name: 'foobar321' %}
        ))
      end

      let(:form_values) { { 'foobar321' => 'blar' } }

      it 'Renders the value into the template' do
        out = template.render('_form_values' => form_values, '_form_stack' => [])
        expect(out).to include('blar')
      end
    end

    context 'default value' do
      let(:template) do
        Solid::Template.parse(%(
          {% form_field name: 'foobar321', default: 'barbaz' %}
        ))
      end

      it 'Uses a default value if _form_values does not include value for tag' do
        out = template.render('_form_stack' => [])
        expect(out).to include('barbaz')
      end
    end
  end

  describe '#form_stack' do
    let(:form_stack) { [] }
    let(:template) do
      Solid::Template.parse(%(
        {% form_field name: 'blar', array: ['one', 2] %}
        {% form_field name: 'foo', hash: { one: 2, 'three' => '4' } %}
        {% form_field name: 'bar' %}
      ))
    end

    it 'adds form elements to the form_stack' do
      template.render('_form_stack' => form_stack)
      expect(form_stack).to include(
        { name: 'blar', array: ['one', 2] },
        { name: 'foo', hash: { one: 2, 'three' => '4' } },
        { name: 'bar' }
      )
    end
  end
end
