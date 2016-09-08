module LiquidVectorGraphic
  module Tags
    describe QueryTag do
      let(:query_field) do
        "{% query_field name: 'foo_bar', collection: [10, 20], method: '#{method}' %}"
      end
      let(:base_date) { nil }
      let(:method) { 'past_date' }
      let(:query) { "SELECT * FROM foo WHERE field >= #{query_field}" }
      let(:template) { Solid::Template.parse(query) }
      let(:form_values) { { 'foo_bar' => '10' } }
      let(:query_tag) { template.nodelist[1] }
      let(:opts) { { '_form_values' => form_values, '_form_stack' => [] } }

      specify { expect(described_class.tag_name).to eq :query_field }

      describe "#display" do
        it 'calls specified method' do
          expect(query_tag).to receive(method)
          template.render(opts)
        end

        it 'removes method from form_tag_options' do
          template.render(opts)
          expect(query_tag.form_tag_options).not_to have_key(:method)
        end

        context 'invalid method' do
          let(:method) { 'not_valid_method' }

          it 'raises InvalidMethodError' do
            expect(template.render(opts)).to include("The method specified is not supported.")
          end
        end

        context 'no method given' do
          let(:query_field) do
            "{% query_field name: 'foo_bar', collection: [10, 20] %}"
          end

          it 'renders using default behavior' do
            expect(template.render(opts)).to eq "SELECT * FROM foo WHERE field >= 10"
          end
        end

        context "date calculations" do
          let(:expected_query) do
            "SELECT * FROM foo WHERE field >= DATE '#{expected_date}'"
          end
          let(:query) { "SELECT * FROM foo WHERE field >= DATE '#{query_field}'" }

          context 'past_date method' do
            let(:expected_date) do
              calculated_date = (base_date || Date.today)
              calculated_date.prev_day(form_values['foo_bar'].to_i).strftime("%Y-%m-%d")
            end

            it 'calculates correct date based on Date.today' do
              expect(template.render(opts)).to eq expected_query
            end

            context '_base_date passed in' do
              let(:base_date) { Date.today.next_day(2) }
              let(:new_opts) { opts.merge({ '_base_date' => base_date }) }

              it 'calculates correct date based on _base_date' do
                expect(template.render(new_opts)).to eq expected_query
              end
            end
          end

          context 'future_date method' do
            let(:method) { 'future_date' }
            let(:expected_date) do
              calculated_date = (base_date || Date.today)
              calculated_date.next_day(form_values['foo_bar'].to_i).strftime("%Y-%m-%d")
            end

            it 'calculates correct date based on Date.today' do
              expect(template.render(opts)).to eq expected_query
            end

            context '_base_date passed in' do
              let(:base_date) { Date.today.next_day(2) }
              let(:new_opts) { opts.merge({ '_base_date' => base_date }) }

              it 'calculates correct date based on _base_date' do
                expect(template.render(new_opts)).to eq expected_query
              end
            end
          end
        end

        context "datetime calculations" do
          let(:expected_query) do
            "SELECT * FROM foo WHERE field >= TIMESTAMP '#{expected_date}'"
          end
          let(:query) { "SELECT * FROM foo WHERE field >= TIMESTAMP '#{query_field}'" }

          context 'past_datetime method' do
            let(:method) { 'past_datetime' }
            let(:expected_date) do
              calculated_date = (base_date || Date.today)
              calculated_date.prev_day(form_values['foo_bar'].to_i).strftime("%Y-%m-%dT%H:%M:%S")
            end

            it 'calculates correct date based on Date.today' do\
              expect(template.render(opts)).to eq expected_query
            end

            context '_base_date passed in' do
              let(:base_date) { Date.today.next_day(2) }
              let(:new_opts) { opts.merge({ '_base_date' => base_date }) }

              it 'calculates correct date based on _base_date' do
                expect(template.render(new_opts)).to eq expected_query
              end
            end
          end

          context 'future_datetime method' do
            let(:method) { 'future_datetime' }
            let(:expected_date) do
              calculated_date = (base_date || Date.today)
              calculated_date.next_day(form_values['foo_bar'].to_i).strftime("%Y-%m-%dT%H:%M:%S")
            end

            it 'calculates correct date based on Date.today' do
              expect(template.render(opts)).to eq expected_query
            end

            context '_base_date passed in' do
              let(:base_date) { Date.today.next_day(2) }
              let(:new_opts) { opts.merge({ '_base_date' => base_date }) }

              it 'calculates correct date based on _base_date' do
                expect(template.render(new_opts)).to eq expected_query
              end
            end
          end
        end
      end

      describe "#valid_methods" do
        subject { query_tag.valid_methods }

        it { is_expected.to eq [:past_date, :past_datetime, :future_date, :future_datetime] }
      end
    end
  end
end
