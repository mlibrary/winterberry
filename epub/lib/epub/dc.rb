module UMPTG::EPUB

  class DC < Node
    attr_reader :elements, :terms

    def initialize(args = {})
      super(args)

      @elements = DCElements.new(args)
      @terms = DCTerms.new(args)
    end

    def find(args = {})
      return @elements.find(args) + @terms.find(args)
    end

    def add(args = {})
      raise "not implemented"
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
