module UMPTG::EPUB::Archive

  class Node < UMPTG::Object
    attr_reader :xpath_children, :rendition

    def initialize(args = {})
      super(args)

      @rendition = args[:rendition]
      @container = args[:container]
      raise "missing rendition" if @rendition.nil? and @container.nil?

      @files_entry = args[:file_entry]
      raise "invalid file_entry" if @files_entry.nil?

      @xpath_node = args[:xpath_node]
      raise "missing node xpath expression" if @xpath_node.nil? or @xpath_node.strip.empty?
      @xpath_children = args[:xpath_children] || "./*"

      @ns_prefix = nil
    end

    def obj_node
      n = @files_entry.document.xpath(@xpath_node).first
      #raise "xpath failure: #{@xpath_node}" if n.nil?
      return n
    end

    def children
      return obj_node.xpath(@xpath_children)
    end

    def find(args = {})
      return children.select {|n| select(n, args) }
    end

    def select(node, args = {})
      return true
    end
  end
end
