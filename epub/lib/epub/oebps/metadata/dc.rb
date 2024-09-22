module UMPTG::EPUB::OEBPS::Metadata

  class DC < UMPTG::EPUB::Node
    attr_reader :elements, :terms

    def initialize(args = {})
      super(args)

      @elements = DCElements.new(args)
      @terms = DCTerms.new(args)

      @xpath_children = @elements.xpath_children + "|" + @terms.xpath_children
    end

    def add(args = {})
      raise "not implemented"
    end

    def select(node, args)
      return (@elements.select(node, args) or @terms.select(node, args))
    end

    def dcterms_modified(args = {})
      metadata_value = args[:metadata_value]
      metadata_node = @rendition.metadata.dc.terms.find(meta_property: 'modified').first
      return metadata_node.content if metadata_value.nil? or metadata_value.empty?

      metadata_node.content = metadata_value
      return metadata_value
    end
  end
end
