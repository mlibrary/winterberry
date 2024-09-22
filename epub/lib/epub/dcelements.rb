module UMPTG::EPUB

  class DCElements < Node

    NAMESPACE_URI = "http://purl.org/dc/elements/1.1/"

    def initialize(args = {})
      a = args.clone
      a[:xpath_children] ="./*[namespace-uri()='#{NAMESPACE_URI}']"
      super(a)

      @ns_prefix = Metadata.namespace_prefix(obj_node, NAMESPACE_URI)
    end

    def title(args = {})
      return find(element_name: "title")
    end

    def identifier(args = {})
      return find(element_name: "identifier")
    end

    def add(args = {})
      raise "not implemented"
    end

    def self.NAMESPACE_URI
      return NAMESPACE_URI
    end
  end
end
