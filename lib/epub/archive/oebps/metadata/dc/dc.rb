module UMPTG::EPUB::Archive::OEBPS::Metadata::DC

  class DC < UMPTG::EPUB::Archive::OEBPS::Metadata::Node
    attr_reader :elements, :terms

    def initialize(args = {})
      a = args.clone
      a[:xpath_node] = "//*[local-name()='metadata']"
      super(a)

      @elements = Elements.new(a)
      @terms = Terms.new(a)

      @xpath_children = @elements.xpath_children + "|" + @terms.xpath_children
    end

    def add(args = {})
      return @elements.add(args) + @terms.add(args)
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
