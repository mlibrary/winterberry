module UMPTG::EPUB::Archive::OEBPS::Metadata::DC

  class Elements < UMPTG::EPUB::Archive::OEBPS::Metadata::Node

    NAMESPACE_URI = "http://purl.org/dc/elements/1.1/"

    ITEM_XML = <<-PKG
<%s:%s/>
    PKG

    def initialize(args = {})
      super(args)

      @ns_prefix = UMPTG::EPUB::Archive::OEBPS::Metadata::Metadata.namespace_prefix(obj_node, NAMESPACE_URI)
      @xpath_children = "./*[namespace-uri()='#{NAMESPACE_URI}']"
    end

    def title(args = {})
      return find(element_name: "title")
    end

    def identifier(args = {})
      return find(element_name: "identifier")
    end

    def add(args = {})
      element_value = args[:element_value] || ""

      mnode_list = find(args)
      if mnode_list.empty?
        element_name = args[:element_name] || ""
        return [] if element_name.empty?

        markup = "<#{@ns_prefix}:#{element_name}/>"
        n = obj_node.add_child(markup)
        mnode_list << n.first unless n.first.nil?
      end
      mnode_list.each {|n| n.content = element_value }
      return mnode_list
    end

    def self.NAMESPACE_URI
      return NAMESPACE_URI
    end
  end
end
