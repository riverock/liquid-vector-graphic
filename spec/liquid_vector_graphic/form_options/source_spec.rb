module LiquidVectorGraphic
  module FormOptions
    describe Source do

      subject { described_class.new(source, parent) }
      let(:parent) { double(:parent) }
      let(:foo_source) { FooSource.new('bar') }
      let(:source) { 'foo/bar' }

      before do
        allow(parent).to receive(:source_for).with('foo', 'bar').and_return(foo_source)
      end

      describe '#form_options' do
        subject { super().form_options }
        it { is_expected.to be_an(Array) }

        it 'calls parent.source_for with correct args' do
          expect(parent).to receive(:source_for).with('foo', 'bar')
          subject
        end

        it 'calls form_options on source resource' do
          expect(foo_source).to receive(:form_options).exactly(1).times
          subject
        end
      end
    end
  end
end
