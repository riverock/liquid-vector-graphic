module LiquidVectorGraphic
  class QueryTemplate < Template
    # @param [String] a templatized SQL^2 query
    def initialize(template)
      self.template = template
    end
  end
end
