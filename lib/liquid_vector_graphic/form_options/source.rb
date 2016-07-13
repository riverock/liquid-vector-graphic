module LiquidVectorGraphic
  module FormOptions
    class Source
      class SourceClassMissing < NameError; end
      class SourceClassResponseInvalid < StandardError; end

      attr_accessor :class_prefix, :scope
      
      def initialize(source_options)
        raise ArgumentError if (source_options.split(?/).count > 2)
        self.class_prefix, self.scope = source_options.split(?/)
      end

      def form_options
        opts = source_klass.new(scope).form_options
        unless opts.kind_of?(Array)
          raise SourceClassResponseInvalid, 'The source class should respond to #form_options with an array.'
        end
        opts
      end

      private

      def source_klass
        klass_name = "#{class_prefix.classify}Source"
        klass_name.constantize
      rescue NameError
        raise SourceClassMissing, "You need to define a class #{klass_name} with #form_options"
      end

    end
  end
end
