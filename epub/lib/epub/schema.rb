module UMPTG::EPUB

  class Schema < Node
    attr_reader :terms

    def initialize(args = {})
      super(args)

      @terms = SchemaTerms.new(args)
      @xpath_children = @terms.xpath_children
    end

    def add(args = {})
      raise "not implemented"
    end

    def select(node, args)
      return @terms.select(node, args)
    end
  end
end
