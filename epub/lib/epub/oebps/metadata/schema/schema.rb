module UMPTG::EPUB::OEBPS::Metadata::Schema

  class Schema < UMPTG::EPUB::Node
    attr_reader :terms

    def initialize(args = {})
      super(args)

      @terms = Terms.new(args)
      @xpath_children = @terms.xpath_children
    end

    def add(args = {})
      return @terms.add(args)
    end

    def select(node, args)
      return @terms.select(node, args)
    end
  end
end
