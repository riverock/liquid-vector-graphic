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
        {% form_field name: 'blar', array: ['one', 2], position: 158, group_name: 'Group 1', group_position: 20 %}
        {% form_field name: 'foo', hash: { one: 2, 'three' => '4' }, position: 28, group_name: 'Group 2', group_position: 10 %}
        {% form_field name: 'bar', position: 20, group_name: 'Group 1', group_position: 3 %}
        {% form_field name: 'foorbar', source: 'foo/bar', default: 'abcdef', as: 'select', group_name: 'Group 2' %}
        {% form_field name: 'fizbaz_multiple', collection: [['Label a', '1'], ['Label b', '2'], ['Label c', '3']], default: ['1', '3'], as: 'select', multiple: true %}
        {% form_field name: 'zipcode', group_name: 'Group 3' %}
        {% form_field name: 'mycollection', collection: ['Name1', 'Name2'] %}
        {% form_field name: 'required_field', required: true %}
        {% form_field name: 'ordered_field', barfoo: 'blar', position: 1 %}
      ))
    end

    let(:expected_name_order) do
      %w(ordered_field bar foo blar fizbaz_multiple foorbar mycollection required_field zipcode)
    end

    it 'returns an array of form field parameters' do
      subject.render()
      expect(subject.form_fields_params).to include(
        ['blar', { array: ['one', 2] }],
        ['foo', { hash: { one: 2, 'three' => '4' } }],
        ['bar', {}],
        ['mycollection', { collection: ['Name1', 'Name2'] }],
        ['required_field', input_html: { required: true }]
      )
    end

    it 'orders the array based on the position attribute' do
      subject.render()
      names = subject.form_fields_params.map { |form| form.first }

      expect(names).to eq expected_name_order
    end

    context 'grouped form fields' do
      let(:groups) do
        subject.render
        subject.grouped_form_fields_params
      end

      it 'groups fields based on group_name' do
        expect(groups.keys).to include('Default', 'Group 1', 'Group 2', 'Group 3')
      end

      it 'removes the group_name key' do
        args_keys = groups.values.inject([]) do |new_array, old_array|
          new_array << old_array.map { |a| a.last.keys }
        end.flatten.uniq
        expect(args_keys).to_not include(:group_name)
      end

      it 'returns array of form_fields with correct structure' do
        values = groups.values.inject([]) { |a, value| value.each { |v| a << v }; a }
        aggregate_failures do
          expect(values.count).to eq subject.form_stack.count
          values.each do |value|
            expect(value).to include(a_kind_of(String)).and include(a_kind_of(Hash))
          end
        end
      end

      it 'assigns group position value based on last field processed for group based on position' do
        subject.render
        subject.grouped_form_fields_params
        expect(subject.send(:form_group_order)).to eq([{'Group 2' => 10}, { 'Group 1' => 20 }, { 'Group 3' => 999 }, { 'Default' => 1000 }])
      end

      it 'orders groups by group_position' do
        expect(groups.keys).to eq ['Group 2', 'Group 1', 'Group 3', 'Default']
      end
    end

    it 'removes the position key' do
      subject.render()
      fields = subject.form_fields_params
      ordered_field = fields.find { |f| f[0] == 'ordered_field' }
      expect(ordered_field).to eq ['ordered_field', barfoo: 'blar']
    end

    it 'Turns the source into a collection' do
      parent = double(:parent, source_for: FooSource.new)
      subject.render({ '_parent' => parent })
      expect(subject.form_fields_params).to include(
        ['foorbar', collection: [[:id, :name], [1234, 'foobar']], selected: 'abcdef', as: 'select']
      )
    end

    it 'sets value if one has already been selected' do
      parent = double(:parent, source_for: FooSource.new)
      subject.render({ '_form_values' => { 'zipcode' => 12345, 'blar' => 'foobazshoe', 'foorbar' => 'zxcvbnm' }, '_parent' => parent })
      expect(subject.form_fields_params).to include(
        ['zipcode', input_html: { value: 12345 }],
        ['blar', { array: ["one", 2], input_html: { value: 'foobazshoe' } }],
        ['foorbar', collection: [[:id, :name], [1234, 'foobar']], selected: 'zxcvbnm', as: 'select']
      )
    end

    it 'sets multiple default values for multiple select' do
      subject.render
      expect(subject.form_fields_params).to include(
        ['fizbaz_multiple', collection: [['Label a', '1'], ['Label b', '2'], ['Label c', '3']], selected: ['1', '3'], as: 'select', multiple: true]
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
          {% form_field name: 'blar1' %}
          {% form_field name: 'blar2', default: 'foobar' %}
          {% form_field name: 'blar3', default: 'barfiz' %}
        ))
      end

      let(:opts) { { '_form_values' => { 'blar1' => 'bizbaz', 'blar3' => 'foobarfoo' } } }
      subject { super().render(opts) }
      it { is_expected.to include('bizbaz') }
      it { is_expected.to include('foobar') }
      it { is_expected.to_not include('barfiz') }
      it { is_expected.to include('foobarfoo') }
    end

    context 'date calculations' do
      let(:template_handle) do
        StringIO.new(%(
          {% form_field name: 'date_field', collection: [10, 20], method: '#{method}' %}
        ))
      end
      let(:form_values) { { 'date_field' => '20' } }

      context "no base date" do
        let(:method) { 'past_date' }
        let(:calculated_date) do
          Date.today.prev_day(form_values['date_field'].to_i).strftime("%m/%d/%Y")
        end

        subject { super().render('_form_values' => form_values).strip }
        it { is_expected.to eq calculated_date }
      end

      context "with base date" do
        let(:method) { 'past_datetime' }
        let(:base_date) { Date.today.next_day(10) }
        let(:calculated_date) do
          base_date.prev_day(form_values['date_field'].to_i).strftime("%m/%d/%Y at %H:%M")
        end

        subject { super().render('_form_values' => form_values, '_base_date' => base_date).strip }
        it { is_expected.to eq calculated_date }
      end
    end
  end

  describe '#template' do
    subject { super().template }
    it { is_expected.to eq File.open(template).read }
  end

end
