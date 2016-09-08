require 'spec_helper'

module LiquidVectorGraphic
  describe QueryTemplate do
    let(:query_tag) do
      "{% query_field name: 'foo_bar', collection: [10, 20] %}"
    end
    let(:template) { "SELECT * FROM foo WHERE field >= #{query_tag}" }

    subject { described_class.new(template) }

    describe '#initialize' do
      context 'template set' do
        subject { super().template }
        it { is_expected.to eq template }
      end
    end
  end
end
