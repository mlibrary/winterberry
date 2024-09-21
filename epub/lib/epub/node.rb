module UMPTG::EPUB

  class Node < UMPTG::Object

    def initialize(args = {})
      super(args)

      @archive_entry = args[:archive_entry]
      raise "invalid archive_entry" if @archive_entry.nil?

      @xpath_node = args[:xpath_node]
      raise "missing node xpath expression" if @xpath_node.nil? or @xpath_node.strip.empty?
      @xpath_children = args[:xpath_children]
      raise "missing items xpath expression" if @xpath_node.nil? or @xpath_node.strip.empty?
    end

    def obj_node
      n = @archive_entry.document.xpath(@xpath_node).first
      raise "xpath failure: #{@xpath_node}" if n.nil?
      return n
    end

    def children
      return @archive_entry.document.xpath(@xpath_children)
    end
  end
end
