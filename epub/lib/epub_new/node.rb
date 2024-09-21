module UMPTG::EPUB

  class Node < UMPTG::Object

    def initialize(args = {})
      super(args)

      @obj = args[:rendition]
      @obj = args[:container] if @obj.nil?

      @xpath_node = args[:xpath_node]
      raise "missing node xpath expression" if @xpath_node.nil? or @xpath_node.strip.empty?
      @xpath_items = args[:xpath_items]
      raise "missing items xpath expression" if @xpath_node.nil? or @xpath_node.strip.empty?
    end

    def obj_node
      n = @obj.aentry.document.xpath(@xpath_node).first
      raise "xpath failure: #{@xpath_node},#{@obj.aentry.document.root.name}" if n.nil?
      return n
    end

    def children
      return @obj.aentry.document.xpath(@xpath_items)
    end
  end
end
