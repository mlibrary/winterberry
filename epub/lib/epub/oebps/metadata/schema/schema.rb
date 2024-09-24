module UMPTG::EPUB::OEBPS::Metadata::Schema

  class Schema < UMPTG::EPUB::OEBPS::Metadata::Node
    attr_reader :terms

    def initialize(args = {})
      a = args.clone
      a[:xpath_node] = "//*[local-name()='metadata']"
      super(a)

      @terms = Terms.new(a)

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
