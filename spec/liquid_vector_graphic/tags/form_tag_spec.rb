describe LiquidVectorGraphic::Tags::FormTag do
  describe '#form_values' do
    let(:template) do
      Solid::Template.parse(%(
        {% form name: 'name' %}
      ))
    end

    let(:form_values) { { name: 'foobar321' } }

    it 'Renders the value into the template' do
      out = template.render('_form_values' => form_values, '_form_stack' => [])
      expect(out).to include('foobar321')
    end

  end


  describe '#form_stack' do
    let(:form_stack) { [] }
    let(:template) do
      Solid::Template.parse(%(
        {% form name: 'blar', array: ['one', 2] %}
        {% form name: 'foo', hash: { one: 2, 'three' => '4' } %}
        {% form name: 'bar' %}
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
