require 'spec_helper'

module LiquidVectorGraphic
  describe QueryTemplate do
    let(:query_tag) do
      "{% query_field name: 'foo_bar', collection: [10, 20] %}"
    end
    let(:template) { "SELECT * FROM foo WHERE field >= '#{query_tag}'" }
    let(:form_values) { { 'foo_bar' => '20' } }

    subject { described_class.new(template) }

    describe '#initialize' do
      context 'template set' do
        subject { super().template }
        it { is_expected.to eq template }
      end
    end

    describe "#render" do
      let(:query_tag) do
        "{% query_field name: 'foo_bar', collection: [10, 20], method: '#{method}' %}"
      end
      let(:expected_query) do
        "SELECT * FROM foo WHERE field >= '#{calculated_date}'"
      end

      context "no base date" do
        let(:method) { 'past_datetime' }
        let(:calculated_date) do
          Date.today.prev_day(form_values['foo_bar'].to_i).strftime("%Y-%m-%dT%H:%M:%SZ")
        end

        subject { super().render('_form_values' => form_values) }
        it { is_expected.to eq expected_query }
      end

      context "with base date" do
        let(:method) { 'past_datetime' }
        let(:base_date) { Date.today.next_day(10) }
        let(:calculated_date) do
          base_date.prev_day(form_values['foo_bar'].to_i).strftime("%Y-%m-%dT%H:%M:%SZ")
        end

        subject { super().render('_form_values' => form_values, '_base_date' => base_date) }
        it { is_expected.to eq expected_query }
      end
    end
  end
end
