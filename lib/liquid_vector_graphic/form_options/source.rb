module LiquidVectorGraphic
  module FormOptions
    class Source
      class SourceClassMissing < NameError; end
      class SourceClassResponseInvalid < StandardError; end

      attr_accessor :resource, :scope, :parent

      def initialize(source_options, parent)
        raise ArgumentError if (source_options.split(?/).count > 2)
        self.resource, self.scope = source_options.split(?/)
        self.parent = parent
      end

      def form_options
        if parent.present?
          parent.source_for(resource, scope).form_options
        else
          []
        end
      end

      def find(value)
        parent.source_for(resource, scope).find(value)
      end
    end
  end
end
