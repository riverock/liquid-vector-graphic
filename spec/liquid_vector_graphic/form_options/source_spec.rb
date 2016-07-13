module LiquidVectorGraphic
  module FormOptions
    describe Source do

      class ::FooSource
        def initialize(*); end
        def form_options
          []
        end
      end

      subject { described_class.new(source) }
      let(:foo_source) { FooSource.new('bar') }
      let(:source) { 'foo/bar' }

      describe '#form_options' do
        subject { super().form_options }
        it { is_expected.to be_an(Array) }

        it 'creates an instance of FooSource' do
          expect(FooSource).to receive(:new).with('bar').and_call_original
          subject
        end

        it 'calls #form_options on source instance' do
          allow(FooSource).to receive(:new).and_return(foo_source)
          expect(foo_source).to receive(:form_options).and_call_original
          subject
        end

        context 'source class missing' do
          let(:source) { 'bar/foo' }
          it 'raises an exception' do
            expect{ subject }.to raise_exception(Source::SourceClassMissing)
          end
        end

        context 'source class does not respond to form_options with an array' do
          it 'raises an exception' do
            allow(FooSource).to receive(:new).and_return(foo_source)
            allow(foo_source).to receive(:form_options).and_return(nil)
            expect{ subject }.to raise_exception(Source::SourceClassResponseInvalid)
          end
        end

      end
    end
  end
end
