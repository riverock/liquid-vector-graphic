module LiquidVectorGraphic
  module FormOptions
    class Source
      class SourceClassMissing < NameError; end
      class SourceClassResponseInvalid < StandardError; end

      attr_accessor :source_key, :scope, :parent

      def initialize(source_options, parent)
        raise ArgumentError if (source_options.split(?/).count > 2)
        self.source_key, self.scope = source_options.split(?/)
        self.parent = parent
      end

      def form_options
        parent.sources[source_key].form_options.send(scope)
      end

      private



    end
  end
end
