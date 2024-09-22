module UMPTG::EPUB::OEBPS::Metadata

  class DCTerms < UMPTG::EPUB::Node
    attr_reader :ns_prefix

    NAMESPACE_URI = "http://purl.org/dc/terms/"

    def initialize(args = {})
      super(args)

      @ns_prefix = Metadata.namespace_prefix(obj_node, NAMESPACE_URI)
      @xpath_children = "./*[local-name()='meta' and starts-with(@property,concat('#{@ns_prefix}',':'))]"
    end

    def modified(args = {})
      return find(meta_property: "modified")
    end

    def add(args = {})
      raise "not implemented"
    end

    def self.NAMESPACE_URI
      return NAMESPACE_URI
    end
  end
end
