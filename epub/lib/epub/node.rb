module UMPTG::EPUB

  class Node < UMPTG::Object
    attr_reader :xpath_children

    def initialize(args = {})
      super(args)

      @rendition = args[:rendition]
      @container = args[:container]
      raise "missing rendition" if @rendition.nil? and @container.nil?

      @archive_entry = args[:archive_entry]
      raise "invalid archive_entry" if @archive_entry.nil?

      @xpath_node = args[:xpath_node]
      raise "missing node xpath expression" if @xpath_node.nil? or @xpath_node.strip.empty?
      @xpath_children = args[:xpath_children]
      raise "missing items xpath expression" if @xpath_node.nil? or @xpath_node.strip.empty?

      @ns_prefix = nil
    end

    def obj_node
      n = @archive_entry.document.xpath(@xpath_node).first
      raise "xpath failure: #{@xpath_node}" if n.nil?
      return n
    end

    def children
      return obj_node.xpath(@xpath_children)
    end

    def find(args = {})
      c_list = children
      return c_list if args[:element_name].nil? and args[:meta_property].nil? and args[:meta_name].nil?
      return c_list.select {|n| select(n, args) }
    end

    def select(node, args = {})
      unless args[:element_name].nil?
        element_name = args[:element_name].strip
        return true unless element_name.empty? \
                or (node.name != element_name)
      end

      meta_property = args[:meta_property]
      meta_property = "" if meta_property.nil?
      meta_name = args[:meta_name]
      meta_name = "" if meta_name.nil?
      return false if meta_property.strip.empty? and meta_name.strip.empty?

      prop = @ns_prefix.nil? ? meta_property : @ns_prefix + ':' + meta_property
      nme = @ns_prefix.nil? ? meta_name : @ns_prefix + ':' + meta_name
      #puts "node:#{node['property']},#{node['name']},#{prop},#{nme},#{@ns_prefix}"
      return (node['property'] == prop or node['name'] == nme)
    end
  end
end
