module LiquidVectorGraphic
  module Tags
    describe FormTag do
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

          context 'text fields' do
            let(:template) do
              Solid::Template.parse(%(
                {% form_field name: 'foobar321', default: 'barbaz' %}
              ))
            end

            it 'Uses a default value without value set' do
              out = template.render('_form_stack' => [])
              expect(out).to include('barbaz')
            end
          end

        end

        context 'no name given to tag' do
          let(:template) do
            Solid::Template.parse(%(
              {% form_field default: 'barbaz' %}
            ))
          end

          it 'it raises Exception' do
            expect { template.render('_form_stack' => []) }.to raise_error NoNameOnFormTagError
          end
        end
      end

      describe '#form_stack' do
        let(:form_stack) { [] }
        let(:template) do
          Solid::Template.parse(%(
            {% form_field name: 'blar', array: ['one', 2], position: 0 %}
            {% form_field name: 'foo', hash: { one: 2, 'three' => '4' }, position: 500 %}
            {% form_field name: 'bar', position: 1 %}
            {% form_field name: 'z_no_position' %}
            {% form_field name: 'a_no_position' %}
          ))
        end

        it 'adds form elements to the form_stack' do
          template.render('_form_stack' => form_stack)
          expect(form_stack).to include(
            { name: 'blar', array: ['one', 2], position: 0 },
            { name: 'foo', hash: { one: 2, 'three' => '4' }, position: 500 },
            { name: 'bar', position: 1 }
          )
        end

      end
    end
  end
end
