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
        {% form name: 'foorbar', source: 'foo/bar', default: 'abcdef', as: 'select' %}
        {% form name: 'zipcode' %}
        {% form name: 'mycollection', collection: ['Name1', 'Name2'] %}
        {% form name: 'required_field', required: true %}
      ))
    end

    it 'Returns an array of form field parameters' do
      subject.render()
      expect(subject.form_fields_params).to include(
        ['blar', { array: ['one', 2] }],
        ['foo', { hash: { one: 2, 'three' => '4' } }],
        ['bar', {}],
        ['mycollection', { collection: ['Name1', 'Name2'] }],
        ['required_field', input_html: { required: true }]
      )
    end

    it 'Turns the source into a collection' do
      subject.render()
      expect(subject.form_fields_params).to include(
        ['foorbar', collection: [[:id, :name], [1234, 'foobar']], input_html: { value: 'abcdef' }, as: 'select']
      )
    end

    it 'sets value if one has already been selected' do
      subject.render({ '_form_values' => { 'zipcode' => 12345, 'blar' => 'foobazshoe', 'foorbar' => 'zxcvbnm' } })
      expect(subject.form_fields_params).to include(
        ['zipcode', input_html: { value: 12345 }],
        ['blar', { array: ["one", 2], input_html: { value: 'foobazshoe' } }],
        ['foorbar', collection: [[:id, :name], [1234, 'foobar']], input_html: { value: 'zxcvbnm' }, as: 'select']
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

    context 'renders passed in form values' do
      let(:template_handle) do
        StringIO.new(%(
          {% form name: 'blar1' %}
          {% form name: 'blar2', default: 'foobar' %}
          {% form name: 'blar3', default: 'barfiz' %}
        ))
      end

      let(:opts) { { '_form_values' => { 'blar1' => 'bizbaz', 'blar3' => 'foobarfoo' } } }
      subject { super().render(opts) }
      it { is_expected.to include('bizbaz') }
      it { is_expected.to include('foobar') }
      it { is_expected.to_not include('barfiz') }
      it { is_expected.to include('foobarfoo') }
    end
  end

  describe '#template' do
    subject { super().template }
    it { is_expected.to eq File.open(template).read }
  end

end
