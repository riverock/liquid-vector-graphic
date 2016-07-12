describe LiquidVectorGraphic::Tags::FormTag do
  let(:form_stack) { [] }

  describe '#form_stack' do
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
