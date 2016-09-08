module LiquidVectorGraphic
  module Tags
    describe QueryTag do
      let(:query_field) do
        "{% query_field name: 'foo_bar', collection: [10, 20], method: '#{method}' %}"
      end
      let(:method) { 'past_date' }
      let(:query) { "SELECT * FROM foo WHERE field >= #{query_field}" }
      let(:template) { Solid::Template.parse(query) }
      let(:form_values) { { 'foo_bar' => 10 } }
      let(:query_tag) { template.nodelist.last }
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
      end

      describe "#valid_methods" do
        subject { query_tag.valid_methods }

        it { is_expected.to eq [:past_date, :past_datetime, :future_date, :future_datetime] }
      end
    end
  end
end
