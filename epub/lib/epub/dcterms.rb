module UMPTG::EPUB

  class DCTerms < Node

    NAMESPACE_URI = "http://purl.org/dc/terms/"

    def initialize(args = {})
      super(args)

      @ns_prefix = Metadata.namespace_prefix(obj_node, NAMESPACE_URI)
      @xpath_children = "//*[local-name()='metadata']/*[local-name()='meta' and starts-with(@property,concat('#{@ns_prefix}',':'))]"
    end

    def modified(args = {})
      return find(meta_property: "modified")
    end

    def find(args = {})
      return children if args.empty?

      return children.select {|n| n['property'] == "#{@ns_prefix}:#{args[:meta_property]}" } \
            unless args[:meta_property].nil?
    end

    def add(args = {})
      raise "not implemented"
    end

    def self.NAMESPACE_URI
      return NAMESPACE_URI
    end
  end
end
