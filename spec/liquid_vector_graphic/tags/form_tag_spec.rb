module LiquidVectorGraphic
  module Tags
    describe FormTag do
      describe '#display' do
        context 'value set' do
          let(:template) do
            Solid::Template.parse(%(
              {% form_field name: 'foobar321' %}
              Value: {{ form_values.foobar321 }}
            ))
          end

          let(:form_values) { { 'foobar321' => 'blar' } }

          it 'Renders the value into the template' do
            out = template.render('_form_values' => form_values, '_form_stack' => [])
            expect(out).to include('blar')
          end

          it 'Captures value for later use' do
            out = template.render('_form_values' => form_values, '_form_stack' => [])
            expect(out).to include('Value: blar')
          end
        end

        context 'default value' do
          context 'text fields' do
            let(:template) do
              Solid::Template.parse(%(
                {% form_field name: 'foobar321', default: 'barbaz' %}
                Value: {{ form_values.foobar321 }}
              ))
            end

            it 'Uses a default value without value set' do
              out = template.render('_form_stack' => [])
              expect(out).to include('barbaz')
            end

            it 'Captures value for later use' do
              out = template.render('_form_stack' => [])
              expect(out).to include('Value: barbaz')
            end
          end

          context 'collection fields' do
            let(:template) do
              Solid::Template.parse(%(
                {% form_field name: 'foobar321', collection: ['one', 'two'], default: 'two' %}
                Value: {{ form_values.foobar321 }}
              ))
            end

            it 'uses the default value without value set' do
              out = template.render('_form_stack' => [])
              expect(out).to include('two')
            end

            it 'Captures value for later use' do
              out = template.render('_form_stack' => [])
              expect(out).to include('Value: two')
            end
          end
        end

        context 'calculated dates' do
          let(:template) do
            Solid::Template.parse(%(
              {% form_field name: 'foobar321', collection: [10, 20], method: '#{method}' %}
            ))
          end
          let(:form_values) { { 'foobar321' => '10' } }

          context 'past_date' do
            let(:method) { 'past_date' }
            let(:calculated_date) do
              Date.today.prev_day(form_values['foobar321'].to_i).strftime("%m/%d/%Y")
            end

            subject { template.render({ '_form_values' => form_values, '_form_stack' => [] }).strip }

            it { is_expected.to eq calculated_date }
          end

          context 'past_datetime' do
            let(:method) { 'past_datetime' }
            let(:calculated_date) do
              Date.today.prev_day(form_values['foobar321'].to_i).strftime("%m/%d/%Y at %H:%M")
            end

            subject { template.render({ '_form_values' => form_values, '_form_stack' => [] }).strip }

            it { is_expected.to eq calculated_date }
          end

          context 'future_date' do
            let(:method) { 'future_date' }
            let(:calculated_date) do
              Date.today.next_day(form_values['foobar321'].to_i).strftime("%m/%d/%Y")
            end

            subject { template.render({ '_form_values' => form_values, '_form_stack' => [] }).strip }

            it { is_expected.to eq calculated_date }
          end

          context 'future_datetime' do
            let(:method) { 'future_datetime' }
            let(:calculated_date) do
              Date.today.next_day(form_values['foobar321'].to_i).strftime("%m/%d/%Y at %H:%M")
            end

            subject { template.render({ '_form_values' => form_values, '_form_stack' => [] }).strip }

            it { is_expected.to eq calculated_date }
          end

          context 'passing in strftime string' do
            let(:template) do
              Solid::Template.parse(%(
                {% form_field name: 'foobar321', collection: [10, 20], method: '#{method}', strftime: '#{strftime}' %}
              ))
            end

            context 'past_date' do
              let(:method) { 'past_date' }
              let(:strftime) { '%m/%d/%y' }
              let(:calculated_date) do
                Date.today.prev_day(form_values['foobar321'].to_i).strftime(strftime)
              end

              subject { template.render({ '_form_values' => form_values, '_form_stack' => [] }).strip }

              it { is_expected.to eq calculated_date }
            end

            context 'past_datetime' do
              let(:method) { 'past_datetime' }
              let(:strftime) { '%m/%d/%y at %H' }
              let(:calculated_date) do
                Date.today.prev_day(form_values['foobar321'].to_i).strftime(strftime)
              end

              subject { template.render({ '_form_values' => form_values, '_form_stack' => [] }).strip }

              it { is_expected.to eq calculated_date }
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

        context 'tag with source attribute' do
          let(:tag_source) { 'foo/bar' }
          let(:template) do
            Solid::Template.parse(%(
              {% form_field name: 'foobar321', source: '#{tag_source}' %}
            ))
          end
          let(:parent) { double(:parent) }

          it 'renders empty string when no selected value passed in' do
            expect(template.render('_form_stack' => []).strip).to eq ""
          end

          it 'calls FormOptions::Source' do
            expect(FormOptions::Source).to receive(:new).with(tag_source, parent)
            template.render('_form_stack' => [], '_form_values' => { 'foobar321' => '1' }, '_parent' => parent)
          end

          context 'finding source value' do
            let(:form_options_source) { FormOptions::Source.new(tag_source, parent) }
            let(:drop) { { 'baz' => 'bar' } }
            let(:template) do
              Solid::Template.parse(%(
                {% form_field name: 'foobar321', source: '#{tag_source}', default: '100' %}
                {{ foobar321.baz }}
              ))
            end

            before do
              allow(FormOptions::Source).to receive(:new).and_return(form_options_source)
              allow(form_options_source).to receive(:find).and_return(drop)
            end

            it 'calls FormOptions::Source#find with passed in form value' do
              expect(form_options_source).to receive(:find).with('1')
              template.render('_form_stack' => [], '_form_values' => { 'foobar321' => '1' }, '_parent' => parent)
            end

            it 'calls FormOptions::Source#find with default value if none passed in' do
              expect(form_options_source).to receive(:find).with('100')
              template.render('_form_stack' => [], '_parent' => parent)
            end

            it 'trys to get display_value from source value' do
              expect(drop).to receive(:try).with(:display_value)
              template.render('_form_stack' => [], '_parent' => parent)
            end

            it 'injects drop into liquid render context' do
              expect(template.render('_form_stack' => [], '_parent' => parent)).to include('bar')
            end
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
