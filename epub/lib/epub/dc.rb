module UMPTG::EPUB

  class DC < Node

    DC_NAMESPACE_URI = "http://purl.org/dc/elements/1.1/"
    DCTERMS_NAMESPACE_URI = "http://purl.org/dc/terms/"

    def initialize(args = {})
      super(args)
    end

    def title(args = {})
      return find(element_name: "title")
    end

    def find(args = {})
      a = args.clone
      a[:namespace_element_uri] = DC_NAMESPACE_URI
      a[:namespace_attribute_uri] = DCTERMS_NAMESPACE_URI
      a[:namespace_attribute_prefix] = Metadata.namespace_prefix(obj_node, DCTERMS_NAMESPACE_URI)

      return @rendition.metadata.find(a)
    end

    def add(args = {})
      raise "not implemented"
    end

    def dcterms_modified(args = {})
      metadata_value = args[:metadata_value]
      metadata_node = find(meta_properties: 'dcterms:modified').first
      return metadata_node.content if metadata_value.nil? or metadata_value.empty?

      metadata_node.content = metadata_value
      return metadata_value
    end

    def self.DC_NAMESPACE_URI
      return DC_NAMESPACE_URI
    end

    def self.DCTERMS_NAMESPACE_URI
      return DCTERMS_NAMESPACE_URI
    end
  end
end
