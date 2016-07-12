require 'spec_helper'

describe LiquidVectorGraphic::Template do
  let(:template) { sample_output_file }
  let(:template_handle) { File.open(template) }
  let(:opts) { {} }
  subject { described_class.new(template_handle)}

  describe '#form_stack' do
    subject { super().form_stack }
    it { is_expected.to eq [] }
  end

  describe '#form_fields_params' do
    let(:template_handle) do
      StringIO.new(%(
        {% form name: 'blar', array: ['one', 2] %}
        {% form name: 'foo', hash: { one: 2, 'three' => '4' } %}
        {% form name: 'bar' %}
      ))
    end

    it 'Returns an array of form field parameters' do
      subject.render()
      expect(subject.form_fields_params).to include(
        ['blar', { array: ['one', 2] }],
        ['foo', { hash: { one: 2, 'three' => '4' } }],
        ['bar', {}]
      )
    end

  end

  describe '#render' do

    context 'Call without interpolation strings' do
      it 'calls the Liquid::Template parser with appropriate args' do
        expect(Liquid::Template).to receive(:parse).with(File.open(template).read)
            .and_call_original
        subject.render(opts)
      end
    end

    context 'call with interpolation on first_object' do
      let(:opts) { { 'first_object' => { 'arbitrary_string' => 'foobar123' } } }
      subject { super().render(opts) }
      it { is_expected.to include('foobar123') }
    end
  end

  describe '#template' do
    subject { super().template }
    it { is_expected.to eq File.open(template).read }
  end

end
